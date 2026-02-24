-- Library Management System SQL project
drop database if exists library_management_system;
create database library_management_system;
use library_management_system;

-- creating branch table
drop table if exists branch;
create table branch(
	branch_id varchar(10) primary key,
	manager_id varchar(10),
	branch_address varchar(55),
	contact_no varchar(20)
);

-- creating employees table
drop table if exists employees;
create table employees(
	emp_id varchar(10) primary key,
	emp_name varchar(20),
	position varchar(15),
	salary float,
	branch_id varchar(10) references branch(branch_id) -- foreign key
);

-- creating books table
drop table if exists books;
create table books(
	isbn varchar(20) primary key,
	book_title varchar(75),
	category varchar(30),
	rental_price float,
	status varchar(15),
	author varchar(35),
	publisher varchar(55)
);

-- creating members table
drop table if exists members;
create table members(
	member_id varchar(10) primary key,
	member_name varchar(25),
	member_address varchar(75),
	reg_date date
);

-- creating issued_status table
drop table if exists issued_status;
create table issued_status(
	issued_id varchar(10) primary key,
	issued_member_id varchar(10) references members(member_id), -- foreign key
	issued_book_name varchar(75),
	issued_date date,
	issued_book_isbn varchar(20) references books(isbn), -- foreign key
	issued_emp_id varchar(10) references employees(emp_id) -- foreign key
);

-- creating return_status table
drop table if exists return_status;
create table return_status(
	return_id varchar(10) primary key,
	issued_id varchar(10) references issued_status(issued_id), -- foreign key
	return_book_name varchar(75),
	return_date date,
	return_book_isbn varchar(20) references books(isbn) -- foreign key
);

-- verifying successfull imports
select * from branch;
select * from employees;
select * from books;
select * from members;
select * from issued_status;
select * from return_status;