-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
select m.member_id, m.member_name, i.issued_book_name, i.issued_date, (current_date - i.issued_date) as days_overdue
from issued_status as i
join members as m on m.member_id = i.issued_member_id
left join return_status as r on r.issued_id = i.issued_id
where r.return_id is null and (current_date - i.issued_date) > 30;

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
create or replace procedure add_return_record(
	p_return_id varchar(10),
	p_issued_id varchar(10),
	p_book_quality varchar(10)
) language plpgsql as
$$
declare
	v_isbn varchar(50);
	v_book_title varchar(80);
begin
	insert into return_status(return_id, issued_id, return_date, book_quality) values
	(p_return_id, p_issued_id, current_date, p_book_quality);

	select issued_book_isbn, issued_book_name from issued_status into
	v_isbn, v_book_title where issued_id = p_issued_id;

	update books
	set status = 'yes' where isbn = v_isbn;

	raise notice 'Thank you for returning the book: %', v_book_title;
end;
$$;

-- Testing FUNCTION add_return_records

-- calling function 
call add_return_record('RS138', 'IS135', 'Good');

-- calling function 
call add_return_record('RS148', 'IS140', 'Good');

-- Task 15: Branch Performance Report (CTAS)
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
drop table if exists branch_reports;
create table branch_reports as
select 
	b.branch_id,
	count(i.issued_id) as issued_book_count,
	count(r.issued_id) as returned_book_count,
	sum(bk.rental_price) as total_revenue
from issued_status as i
join employees as e on e.emp_id = i.issued_emp_id
join branch as b on b.branch_id = e.branch_id
left join return_status as r on r.issued_id = i.issued_id
join books as bk on bk.isbn = i.issued_book_isbn
group by b.branch_id;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
drop table if exists active_members;
create table active_members as
select * from members where member_id in (
	select distinct member_id from issued_status
	where issued_date >= current_date - interval '2 months'
);

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
select 
	e.emp_name,
	b.*,
	count(i.issued_id) as book_issue_count
from employees as e
join issued_status as i on i.issued_emp_id = e.emp_id
join branch as b on b.branch_id = e.branch_id
group by 1, 2
order by count(i.issued_id) desc limit 3;

-- Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
create or replace procedure issue_book(
	p_isbn varchar(20),
	p_issued_id varchar(10),
	p_member_id varchar(10),
	p_emp_id varchar(10)
) language plpgsql as
$$
declare
	v_status varchar(10);
	v_book_title varchar(75);
begin
	-- get the book
	select book_title, status into v_book_title, v_status
	from books where isbn = p_isbn;
	-- check status
	if v_status = 'yes' then
		-- insert into issued_status
		insert into issued_status values
		(p_issued_id, p_member_id, v_book_title, current_date, p_isbn, p_emp_id);
		-- update status in books table
		update books
		set status = 'no' where isbn = p_isbn;
		-- print a success message
		raise notice 'Book isbn: % issued successfully', p_isbn;
	else
		-- print a failure message
		raise notice 'Book isbn: % not available', p_isbn;
	end if;
end;
$$;

-- Testing
call issue_book('978-0-553-29698-2', 'IS155', 'C106', 'E104');
call issue_book('978-0-553-29698-2', 'IS156', 'C106', 'E104');