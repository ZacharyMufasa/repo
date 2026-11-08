-- Load raw CSV values as text before cleaning them.

CREATE TABLE stg_members (
    `member_id` VARCHAR(255),
    `first_name` VARCHAR(255),
    `last_name` VARCHAR(255),
    `email` VARCHAR(255),
    `zip` VARCHAR(255),
    `joined` VARCHAR(255),
    `status` VARCHAR(255)
);

LOAD DATA LOCAL INFILE 'data/members.csv'
INTO TABLE stg_members
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`member_id`, `first_name`, `last_name`, `email`, `zip`, `joined`, `status`);

CREATE TABLE stg_categories (
    `category_id` VARCHAR(255),
    `name` VARCHAR(255),
    `daily_late_fee` VARCHAR(255),
    `max_loan_days` VARCHAR(255),
    `requires_cert` VARCHAR(255)
);

LOAD DATA LOCAL INFILE 'data/categories.csv'
INTO TABLE stg_categories
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`category_id`, `name`, `daily_late_fee`, `max_loan_days`, `requires_cert`);

CREATE TABLE stg_certifications (
    `member_email` VARCHAR(255),
    `category` VARCHAR(255),
    `certified_on` VARCHAR(255)
);

LOAD DATA LOCAL INFILE 'data/certifications.csv'
INTO TABLE stg_certifications
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`member_email`, `category`, `certified_on`);

CREATE TABLE stg_inventory (
    `tool_id` VARCHAR(255),
    `name` VARCHAR(255),
    `brand` VARCHAR(255),
    `category` VARCHAR(255),
    `purchased` VARCHAR(255),
    `price` VARCHAR(255),
    `tool_condition` VARCHAR(255)
);

LOAD DATA LOCAL INFILE 'data/inventory.csv'
INTO TABLE stg_inventory
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`tool_id`, `name`, `brand`, `category`, `purchased`, `price`, `tool_condition`);

CREATE TABLE stg_loans (
    `loan_id` VARCHAR(255),
    `tool_id` VARCHAR(255),
    `tool_name` VARCHAR(255),
    `category` VARCHAR(255),
    `member_email` VARCHAR(255),
    `member_name` VARCHAR(255),
    `member_zip` VARCHAR(255),
    `out_date` VARCHAR(255),
    `due_date` VARCHAR(255),
    `back_date` VARCHAR(255),
    `staff_email` VARCHAR(255),
    `fee_charged` VARCHAR(255)
);

LOAD DATA LOCAL INFILE 'data/loans.csv'
INTO TABLE stg_loans
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`loan_id`, `tool_id`, `tool_name`, `category`, `member_email`, `member_name`, `member_zip`, `out_date`, `due_date`, `back_date`, `staff_email`, `fee_charged`);

CREATE TABLE stg_staff (
    `staff_id` VARCHAR(255),
    `first_name` VARCHAR(255),
    `last_name` VARCHAR(255),
    `email` VARCHAR(255)
);

LOAD DATA LOCAL INFILE 'data/staff.csv'
INTO TABLE stg_staff
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`staff_id`, `first_name`, `last_name`, `email`);

-- Reference rows are inserted before rows that depend on them.
INSERT INTO category (category_id, name, daily_late_fee, max_loan_days, requires_certification)
SELECT category_id, TRIM(name), daily_late_fee, max_loan_days,
       CASE WHEN UPPER(TRIM(requires_cert)) = 'Y' THEN 1 ELSE 0 END
FROM stg_categories;

INSERT INTO member (member_id, first_name, last_name, email, zip, join_date, status)
SELECT m.member_id, m.first_name, m.last_name, LOWER(TRIM(m.email)),
       LPAD(TRIM(m.zip), 5, '0'), CASE WHEN TRIM(m.joined) LIKE '%/%' THEN STR_TO_DATE(TRIM(m.joined), '%m/%d/%Y') ELSE STR_TO_DATE(TRIM(m.joined), '%Y-%m-%d') END,
       REPLACE(LOWER(TRIM(m.status)), ' ', '_')
FROM stg_members m
WHERE NOT EXISTS (
    SELECT 1 FROM stg_members other
    WHERE LOWER(TRIM(other.email)) = LOWER(TRIM(m.email))
      AND CAST(other.member_id AS UNSIGNED) < CAST(m.member_id AS UNSIGNED)
);

INSERT INTO staff (staff_id, first_name, last_name, email)
SELECT staff_id, first_name, last_name, LOWER(TRIM(email)) FROM stg_staff;

INSERT INTO tool (tool_id, name, brand, category_id, purchase_date, purchase_price, tool_condition)
SELECT i.tool_id, i.name, i.brand, c.category_id, CASE WHEN TRIM(i.purchased) LIKE '%/%' THEN STR_TO_DATE(TRIM(i.purchased), '%m/%d/%Y') ELSE STR_TO_DATE(TRIM(i.purchased), '%Y-%m-%d') END,
       REPLACE(REPLACE(TRIM(i.price), '$', ''), ',', ''),
       REPLACE(LOWER(TRIM(i.tool_condition)), ' ', '_')
FROM stg_inventory i
JOIN category c ON LOWER(TRIM(i.category)) = LOWER(TRIM(c.name));

INSERT INTO certification (member_id, category_id, certified_on)
SELECT m.member_id, c.category_id, CASE WHEN TRIM(s.certified_on) LIKE '%/%' THEN STR_TO_DATE(TRIM(s.certified_on), '%m/%d/%Y') ELSE STR_TO_DATE(TRIM(s.certified_on), '%Y-%m-%d') END
FROM stg_certifications s
JOIN member m ON m.email = LOWER(TRIM(s.member_email))
JOIN category c ON LOWER(TRIM(c.name)) = LOWER(TRIM(s.category));

INSERT INTO checkout (checkout_id, tool_id, member_id, staff_id, checkout_date, due_date, return_date, late_fee)
SELECT DISTINCT l.loan_id, t.tool_id, m.member_id, s.staff_id,
       CASE WHEN TRIM(l.out_date) LIKE '%/%' THEN STR_TO_DATE(TRIM(l.out_date), '%m/%d/%Y') ELSE STR_TO_DATE(TRIM(l.out_date), '%Y-%m-%d') END, CASE WHEN TRIM(l.due_date) LIKE '%/%' THEN STR_TO_DATE(TRIM(l.due_date), '%m/%d/%Y') ELSE STR_TO_DATE(TRIM(l.due_date), '%Y-%m-%d') END,
       CASE WHEN TRIM(l.back_date) = '' THEN NULL ELSE CASE WHEN TRIM(l.back_date) LIKE '%/%' THEN STR_TO_DATE(TRIM(l.back_date), '%m/%d/%Y') ELSE STR_TO_DATE(TRIM(l.back_date), '%Y-%m-%d') END END,
       CASE WHEN TRIM(l.back_date) = '' THEN 0
            ELSE GREATEST(DATEDIFF(CASE WHEN TRIM(l.back_date) LIKE '%/%' THEN STR_TO_DATE(TRIM(l.back_date), '%m/%d/%Y') ELSE STR_TO_DATE(TRIM(l.back_date), '%Y-%m-%d') END, CASE WHEN TRIM(l.due_date) LIKE '%/%' THEN STR_TO_DATE(TRIM(l.due_date), '%m/%d/%Y') ELSE STR_TO_DATE(TRIM(l.due_date), '%Y-%m-%d') END), 0) * c.daily_late_fee END
FROM stg_loans l
JOIN tool t ON t.tool_id = l.tool_id
JOIN category c ON c.category_id = t.category_id
JOIN member m ON m.email = LOWER(TRIM(l.member_email))
JOIN staff s ON s.email = LOWER(TRIM(l.staff_email))
WHERE TRIM(l.back_date) = '' OR CASE WHEN TRIM(l.back_date) LIKE '%/%' THEN STR_TO_DATE(TRIM(l.back_date), '%m/%d/%Y') ELSE STR_TO_DATE(TRIM(l.back_date), '%Y-%m-%d') END >= CASE WHEN TRIM(l.out_date) LIKE '%/%' THEN STR_TO_DATE(TRIM(l.out_date), '%m/%d/%Y') ELSE STR_TO_DATE(TRIM(l.out_date), '%Y-%m-%d') END;
