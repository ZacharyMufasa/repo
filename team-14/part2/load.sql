
-- members
CREATE TABLE stg_members LIKE members;

LOAD DATA LOCAL INFILE  "C:\Users\zacha\Documents\Clemson Coursework\Fall 2026\CPSC 6620\dataproject\team-14\data\members.csv"
INTO TABLE stg_members
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(member_id, first_name, last_name, email, zip, joined, status);

SELECT * FROM stg_members;

INSERT INTO MEMBERS(member_id, first_name, last_name, email, zip, joined, status)
SELECT member_id, first_name, last_name, email, zip, joined, status FROM stg_members;


-- categories
CREATE TABLE stg_categories LIKE categories;

LOAD DATA LOCAL INFILE  'C:\Users\zacha\Documents\Clemson Coursework\Fall 2026\CPSC 6620\dataproject\team-14\data\categories.csv'
INTO TABLE stg_categories
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(category_id, name, daily_late_fee, max_loan_days, requires_cert);

SELECT * FROM stg_categories;

INSERT INTO categories(category_id, name, daily_late_fee, max_loan_days, requires_cert)
SELECT category_id, name, daily_late_fee, max_loan_days, requires_cert FROM stg_categories;


-- certifications
CREATE TABLE stg_certifications LIKE certifications;

LOAD DATA LOCAL INFILE  'C:\Users\zacha\Documents\Clemson Coursework\Fall 2026\CPSC 6620\dataproject\team-14\data\certifications.csv'
INTO TABLE stg_certifications
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(member_email, category, certified_on);

SELECT * FROM stg_certifications;

INSERT INTO certifications(member_email, category, certified_on)
SELECT member_email, category, certified_on FROM stg_certifications;

-- inventory
CREATE TABLE stg_inventory LIKE inventory;

LOAD DATA LOCAL INFILE  'C:\Users\zacha\Documents\Clemson Coursework\Fall 2026\CPSC 6620\dataproject\team-14\data\inventory.csv'
INTO TABLE stg_inventory
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(tool_id, name, brand, category, purchased, price, `condition`);

SELECT * FROM stg_inventory;

INSERT INTO inventory(tool_id, name, brand, category, purchased, price, condition)
SELECT tool_id, name, brand, category, purchased, price, `condition` FROM stg_inventory;

-- loans
CREATE TABLE stg_loans LIKE loans;

LOAD DATA LOCAL INFILE  "C:\Users\zacha\Documents\Clemson Coursework\Fall 2026\CPSC 6620\dataproject\team-14\data\loans.csv"
INTO TABLE stg_loans
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(loan_id,tool_id, tool_name, category, member_email, member_name, member_zip, out_date, due_date, back_date, staff_email, fee_charged);

SELECT * FROM stg_loans;

INSERT INTO loans(loan_id,tool_id, tool_name, category, member_email, member_name, member_zip, out_date, due_date, back_date, staff_email, fee_charged)
SELECT loan_id, tool_id, tool_name, category, member_email, member_name, member_zip, out_date, due_date, back_date, staff_email, fee_charged FROM stg_loans;


-- loans
CREATE TABLE stg_staff LIKE staff;

LOAD DATA LOCAL INFILE  "C:\Users\zacha\Documents\Clemson Coursework\Fall 2026\CPSC 6620\dataproject\team-14\data\staff.csv"
INTO TABLE stg_staff
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(staff_id, first_name, last_name, email);

SELECT * FROM stg_staff;

INSERT INTO staff(staff_id, first_name, last_name, email)
SELECT staff_id, first_name, last_name, email
FROM stg_staff;
