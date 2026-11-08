-- CHECK constraints require MySQL 8.0.16 or newer.
CREATE TABLE category(
	category_id INT PRIMARY KEY NOT NULL,
	name VARCHAR(50) UNIQUE NOT NULL,
	daily_late_fee DECIMAL(6,2) NOT NULL,
	max_loan_days INT NOT NULL,
	requires_certification BOOLEAN NOT null,
	CONSTRAINT chk_category_daily_late_fee CHECK (daily_late_fee >= 0),
	CONSTRAINT chk_category_max_loan_days CHECK (max_loan_days >= 1)
);

CREATE TABLE member(
	member_id INT PRIMARY KEY NOT NULL,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(100) UNIQUE NOT NULL,
	zip CHAR(5) NOT NULL,
	join_date DATE NOT NULL,
	status ENUM('active', 'suspended') NOT NULL
);

CREATE TABLE staff(
	staff_id INT PRIMARY KEY NOT NULL,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE tool(
	tool_id INT PRIMARY KEY NOT NULL,
	name VARCHAR(100) NOT NULL,
	brand VARCHAR(50) NOT NULL,
	category_id INT NOT NULL,
	purchase_date DATE NOT NULL,
	purchase_price DECIMAL(8,2) NOT NULL,
	tool_condition ENUM('good','fair','needs_repair','retired') NOT NULL,
	FOREIGN KEY(category_id) REFERENCES category(category_id),
	CONSTRAINT chk_tool_purchase_price CHECK (purchase_price >= 0)
);

CREATE TABLE certification(
    member_id INT NOT NULL,
    FOREIGN KEY(member_id) REFERENCES member(member_id),
    category_id INT NOT NULL,
    FOREIGN KEY(category_id) REFERENCES category(category_id),
    PRIMARY KEY(member_id, category_id),
    certified_on DATE NOT NULL
);

CREATE TABLE checkout(
    checkout_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tool_id INT NOT NULL,
    FOREIGN KEY(tool_id) REFERENCES tool(tool_id),
    member_id INT NOT NULL,
    FOREIGN KEY(member_id) REFERENCES member(member_id),
    staff_id INT NOT NULL,
    FOREIGN KEY(staff_id) REFERENCES staff(staff_id),
    checkout_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    late_fee DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT chk_checkout_due_date CHECK (due_date >= checkout_date),
    CONSTRAINT chk_checkout_return_date CHECK (return_date IS NULL OR return_date >= checkout_date),
    CONSTRAINT chk_checkout_late_fee CHECK (late_fee >= 0)
);
