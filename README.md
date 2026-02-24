# SQL-library-management-system
---

# 📚 SQL Library Management System

## 📌 Project Overview

This repository contains a fully functional, relational Library Management System built entirely using SQL and PL/pgSQL. It spans the complete database lifecycle: from designing the schema and ensuring referential integrity (DDL), to performing routine library operations (DML), and finally automating complex workflows using advanced stored procedures and analytical queries.

This project is optimized for PostgreSQL and demonstrates proficiency in relational database architecture, multi-table joins, date/time manipulation, dynamic table creation (CTAS), and procedural SQL.

---

## 🗄️ Phase 1: Database Architecture (DDL) & Schema Design

The foundation of this Library Management System is built on a highly normalized relational database schema. The Data Definition Language (DDL) scripts are responsible for initializing the database environment and constructing six interconnected tables.

The schema is divided into **Master Tables** (storing static entity data) and **Transactional Tables** (storing operational event logs), utilizing Primary Keys (PK) and Foreign Keys (FK) to enforce strict referential integrity.

### 1. Database Initialization

Before constructing the tables, the environment is prepped by dropping any existing conflicting database and establishing a fresh schema.

```sql
-- Library Management System SQL project
DROP DATABASE IF EXISTS library_management_system;
CREATE DATABASE library_management_system;

```

### 2. Master Tables (Entity Data)

These tables hold the core dimensional data of the library—its locations, staff, inventory, and patrons.

**A. Branch & Employees**
The `branch` table tracks physical library locations, while the `employees` table maps staff to those specific branches.

```sql
-- Creating branch table
DROP TABLE IF EXISTS branch;
CREATE TABLE branch(
	branch_id VARCHAR(10) PRIMARY KEY,
	manager_id VARCHAR(10),
	branch_address VARCHAR(55),
	contact_no VARCHAR(20)
);

-- Creating employees table
DROP TABLE IF EXISTS employees;
CREATE TABLE employees(
	emp_id VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(20),
	position VARCHAR(15),
	salary FLOAT,
	branch_id VARCHAR(10) REFERENCES branch(branch_id) -- FK to branch
);

```

**B. Books Inventory**
The master inventory table tracking metadata and real-time availability.

```sql
-- Creating books table
DROP TABLE IF EXISTS books;
CREATE TABLE books(
	isbn VARCHAR(20) PRIMARY KEY,
	book_title VARCHAR(75),
	category VARCHAR(30),
	rental_price FLOAT,
	status VARCHAR(15),
	author VARCHAR(35),
	publisher VARCHAR(55)
);

```

**C. Members**
Tracks registered library patrons.

```sql
-- Creating members table
DROP TABLE IF EXISTS members;
CREATE TABLE members(
	member_id VARCHAR(10) PRIMARY KEY,
	member_name VARCHAR(25),
	member_address VARCHAR(75),
	reg_date DATE
);

```

### 3. Transactional Tables (Operational Data)

These tables record the day-to-day operations of the library. They rely heavily on foreign keys to link patrons, staff, and inventory together securely.

**A. Issued Status (Checkouts)**
Logs every time a book leaves the library. It links four separate data points: the transaction ID, the patron, the book, and the employee who authorized it.

```sql
-- Creating issued_status table
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status(
	issued_id VARCHAR(10) PRIMARY KEY,
	issued_member_id VARCHAR(10) REFERENCES members(member_id), -- FK to members
	issued_book_name VARCHAR(75),
	issued_date DATE,
	issued_book_isbn VARCHAR(20) REFERENCES books(isbn), -- FK to books
	issued_emp_id VARCHAR(10) REFERENCES employees(emp_id) -- FK to employees
);

```

**B. Return Status (Check-ins)**
Logs the completion of a transaction, assessing the book's quality upon return and referencing the original checkout ID.

```sql
-- Creating return_status table
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status(
	return_id VARCHAR(10) PRIMARY KEY,
	issued_id VARCHAR(10) REFERENCES issued_status(issued_id), -- FK to issued_status
	return_book_name VARCHAR(75),
	return_date DATE,
	return_book_isbn VARCHAR(20) REFERENCES books(isbn) -- FK to books
);

```

### 🔗 Referential Integrity Map

To prevent orphaned records and maintain data consistency, the following constraint architecture was implemented:

* **`employees.branch_id`** → Must exist in **`branch.branch_id`**
* **`issued_status.issued_member_id`** → Must exist in **`members.member_id`**
* **`issued_status.issued_book_isbn`** → Must exist in **`books.isbn`**
* **`issued_status.issued_emp_id`** → Must exist in **`employees.emp_id`**
* **`return_status.issued_id`** → Must exist in **`issued_status.issued_id`**
* **`return_status.return_book_isbn`** → Must exist in **`books.isbn`**

---

## 🟢 Phase 2: Core Library Operations (CRUD & Basic Queries)

This phase handles the day-to-day administrative tasks of the library, utilizing fundamental SQL commands.

**Task 1: Add a New Book Record**

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

```

**Task 2: Update Member Details**

```sql
UPDATE members
SET member_address = '167 Main St'
WHERE member_id = 'C101';

```

**Task 3: Safely Delete Records**

```sql
-- Using CASCADE to handle dependent records if necessary
DELETE FROM issued_status CASCADE WHERE issued_id = 'IS121';

```

**Task 4: Employee Workflow Tracking**

```sql
-- Retrieve all books processed by a specific employee
SELECT * FROM issued_status WHERE issued_emp_id = 'E101';

```

**Task 7: Inventory Filtering**

```sql
-- Retrieve all books in a specific category
SELECT * FROM books WHERE category = 'Classic';

```

**Task 9: Track Recent Registrations**

```sql
-- List members who joined in the last 180 days using date intervals
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

```

---

## 🟡 Phase 3: Intermediate Analytics & Reporting

These queries extract meaningful business intelligence by aggregating data, joining multiple tables, and generating new summary tables dynamically.

**Task 5: Identify Highly Active Members**

```sql
-- Find members who have issued more than one book
SELECT issued_member_id, COUNT(*) AS book_count 
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1;

```

**Task 6 & 11: Dynamic Summary Tables (CTAS)**

```sql
-- Task 6: Create a summary table of issue counts per book
DROP TABLE IF EXISTS issued_book_cnt;
CREATE TABLE issued_book_cnt AS
SELECT b.isbn, b.book_title, COUNT(*)
FROM books AS b 
JOIN issued_status AS i ON i.issued_book_isbn = b.isbn
GROUP BY b.isbn;

-- Task 11: Create a table of premium inventory (price > $7)
DROP TABLE IF EXISTS expensive_books;
CREATE TABLE expensive_books AS
SELECT * FROM books WHERE rental_price > 7;

```

**Task 8: Revenue by Category**

```sql
-- Calculate total rental income grouped by book category
SELECT b.category, SUM(b.rental_price), COUNT(*)
FROM books AS b 
JOIN issued_status AS i ON i.issued_book_isbn = b.isbn
GROUP BY b.category;

```

**Task 10: Organizational Hierarchy (Self/Multi-Joins)**

```sql
-- List employees alongside their branch manager's name
SELECT e1.*, e2.emp_name AS manager_name, b.* FROM employees AS e1
JOIN branch AS b ON b.branch_id = e1.branch_id
JOIN employees AS e2 ON b.manager_id = e2.emp_id;

```

**Task 12: Identify Unreturned Inventory**

```sql
-- Find books that have been issued but not yet returned
SELECT i.issued_book_isbn, i.issued_book_name 
FROM issued_status AS i
LEFT JOIN return_status AS r ON r.issued_id = i.issued_id
WHERE r.return_id IS NULL;

```

---

## 🔴 Phase 4: Advanced Automation & Complex Queries

The final phase focuses on automating operational logic using stored procedures and executing complex analytical aggregations.

**Task 13: Overdue Book Tracking**

```sql
-- Identify overdue books assuming a 30-day return period
SELECT 
	m.member_id, m.member_name, i.issued_book_name, i.issued_date, 
	(CURRENT_DATE - i.issued_date) AS days_overdue
FROM issued_status AS i
JOIN members AS m ON m.member_id = i.issued_member_id
LEFT JOIN return_status AS r ON r.issued_id = i.issued_id
WHERE r.return_id IS NULL AND (CURRENT_DATE - i.issued_date) > 30;

```

**Task 15: Branch Performance Dashboard**

```sql
-- Generate a holistic performance report for each branch
DROP TABLE IF EXISTS branch_reports;
CREATE TABLE branch_reports AS
SELECT 
	b.branch_id,
	COUNT(i.issued_id) AS issued_book_count,
	COUNT(r.issued_id) AS returned_book_count,
	SUM(bk.rental_price) AS total_revenue
FROM issued_status AS i
JOIN employees AS e ON e.emp_id = i.issued_emp_id
JOIN branch AS b ON b.branch_id = e.branch_id
LEFT JOIN return_status AS r ON r.issued_id = i.issued_id
JOIN books AS bk ON bk.isbn = i.issued_book_isbn
GROUP BY b.branch_id;

```

**Task 16: Active Member Segmentation**

```sql
-- Create a table of members who issued a book in the last 2 months
DROP TABLE IF EXISTS active_members;
CREATE TABLE active_members AS
SELECT * FROM members WHERE member_id IN (
	SELECT DISTINCT member_id FROM issued_status
	WHERE issued_date >= CURRENT_DATE - INTERVAL '2 months'
);

```

**Task 17: Top Performing Employees**

```sql
-- Find the top 3 employees by volume of books processed
SELECT 
	e.emp_name, b.*, COUNT(i.issued_id) AS book_issue_count
FROM employees AS e
JOIN issued_status AS i ON i.issued_emp_id = e.emp_id
JOIN branch AS b ON b.branch_id = e.branch_id
GROUP BY 1, 2
ORDER BY COUNT(i.issued_id) DESC LIMIT 3;

```

### Automated Workflows (Stored Procedures)

**Task 18: Automated Book Issuance System**
This PL/pgSQL procedure verifies inventory availability before processing a checkout, updating master records, and returning success/failure alerts.

```sql
CREATE OR REPLACE PROCEDURE issue_book(
	p_isbn VARCHAR(20), p_issued_id VARCHAR(10), p_member_id VARCHAR(10), p_emp_id VARCHAR(10)
) LANGUAGE plpgsql AS $$
DECLARE
	v_status VARCHAR(10);
	v_book_title VARCHAR(75);
BEGIN
	-- Check availability
	SELECT book_title, status INTO v_book_title, v_status FROM books WHERE isbn = p_isbn;
	
	IF v_status = 'yes' THEN
		-- Log issuance & update availability
		INSERT INTO issued_status VALUES (p_issued_id, p_member_id, v_book_title, CURRENT_DATE, p_isbn, p_emp_id);
		UPDATE books SET status = 'no' WHERE isbn = p_isbn;
		RAISE NOTICE 'Book isbn: % issued successfully', p_isbn;
	ELSE
		RAISE NOTICE 'Book isbn: % not available', p_isbn;
	END IF;
END;
$$;

```

**Task 14: Automated Return Processing**
This procedure logs a returned book and automatically flips its availability status back to 'yes'.

```sql
CREATE OR REPLACE PROCEDURE add_return_record(
	p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10)
) LANGUAGE plpgsql AS $$
DECLARE
	v_isbn VARCHAR(50);
	v_book_title VARCHAR(80);
BEGIN
	-- Log return
	INSERT INTO return_status(return_id, issued_id, return_date, book_quality) 
	VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

	-- Fetch ISBN and update availability
	SELECT issued_book_isbn, issued_book_name INTO v_isbn, v_book_title 
	FROM issued_status WHERE issued_id = p_issued_id;

	UPDATE books SET status = 'yes' WHERE isbn = v_isbn;
	RAISE NOTICE 'Thank you for returning the book: %', v_book_title;
END;
$$;

```

---

## 🛠️ Key Technical Skills Demonstrated

* **Database Design**: Normalization, Primary/Foreign Key constraints, Entity-Relationship modeling.
* **Data Manipulation**: Standard CRUD operations, batch updates, and safe deletions.
* **Complex Data Retrieval**: `INNER JOIN`, `LEFT JOIN`, Self-Joins, and Subqueries.
* **Data Aggregation**: `GROUP BY`, `HAVING`, `SUM`, `COUNT`.
* **Dynamic Tables**: `CREATE TABLE AS` (CTAS) for on-the-fly reporting.
* **Date & Time Operations**: Interval arithmetic (`CURRENT_DATE - INTERVAL`).
* **Procedural Programming (PL/pgSQL)**: Variables, Conditional Logic (`IF/ELSE`), Status Updates, and `RAISE NOTICE` outputs.

---
