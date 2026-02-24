-- Task 1: Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books(isbn, book_title, category, rental_price, status, author, publisher)
values
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;

-- Task 2: Update an Existing Member's Address
update members
set member_address = '167 Main St'
where member_id = 'C101';
select * from members where member_id = 'C101';

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status cascade where issued_id = 'IS121';
select * from issued_status where issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status where issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_member_id, count(*) as book_count from issued_status
group by issued_member_id
having count(*) > 1;

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
drop table if exists issued_book_cnt;
create table issued_book_cnt as
select b.isbn, b.book_title, count(*)
from books as b join issued_status as i on i.issued_book_isbn = b.isbn
group by b.isbn;

-- Task 7: Retrieve All Books in a Specific Category
select * from books where category = 'Classic';

-- Task 8: Find Total Rental Income by Category
select b.category, sum(b.rental_price), count(*)
from books as b join issued_status as i on i.issued_book_isbn = b.isbn
group by b.category;

-- Task 9: List Members Who Registered in the Last 180 Days
select * from members
where reg_date >= current_date - interval '180 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details
select e1.*, e2.emp_name as manager_name, b.* from employees as e1
join branch as b on b.branch_id = e1.branch_id
join employees as e2 on b.manager_id = e2.emp_id;

-- Task 11: Create a Table of Books with Rental Price Above a Certain Threshold
drop table if exists expensive_books;
create table expensive_books as
select * from books where rental_price > 7;

-- Task 12: Retrieve the List of Books Not Yet Returned
select i.issued_book_isbn, i.issued_book_name from issued_status as i
left join return_status as r on r.issued_id = i.issued_id
where r.return_id is null;