-- create book list table
drop table if exists books;
create table books (
    book_id serial primary key,
    title varchar(100),
    author varchar(100),
    genre varchar(50),
    published_year int,
    price numeric(10, 2),
    stock int
);

-- create customer list table
drop table if exists customers;
create table customers (
    customer_id serial primary key,
    name varchar(100),
    email varchar(100),
    phone varchar(15),
    city varchar(50),
    country varchar(150)
);

-- create order list table
drop table if exists orders;
create table orders (
    order_id serial primary key,
    customer_id int references customers(customer_id),
    book_id int references books(book_id),
    order_date date,
    quantity int,
    total_amount numeric(10, 2)
);

select * from books;
select * from customers;
select * from orders;



--importing data from csv file into books table

copy books(book_id, title, author, genre, published_year, price, stock)
from 'd:/sql/project 1/online book store/Books.csv'
csv header;


--importing data from csv file into customers table
copy customers(customer_id, name, email, phone, city, country) 
from 'd:/sql/project 1/online book store/customers.csv' 
csv header;


--importing data from csv file into orders table
copy orders(order_id, customer_id, book_id, order_date, quantity, total_amount) 
from 'd:/sql/project 1/online book store/orders.csv' 
csv header;

/* 
Basic Questions:
1) Retrieve all books in the "Fiction" genre
2) Find books published after the year 1950
3) List all customers from the Canada
4) Show orders placed in November 2023
5) Retrieve the total stock of books available
6) Retrieve the 2nd most expensive book available
7) Show all customers who ordered more than 1 quantity of a book
8) Retrieve all orders where the total amount exceeds $20
9) List all genres available in the Books table
10) List all genre with sold quantity
11) Find the book with the lowest stock
12) Calculate the total revenue generated from all orders
13) Find the average price of books in the "Fantasy" genre
*/



/*  
Advance Questions: 
1) Retrieve the total number of books sold for each genre
2) List customers who have placed at least 2 orders
3) Find the most frequently ordered book
4) Show the top 3 most expensive books of 'Fantasy' Genre
5) Retrieve the total quantity of books sold by each author
6) List the cities where customers who spent over $30 are located
7) Find the customer who spent the most on orders
8) Calculate the stock remaining after fulfilling all orders
*/


-- 1) Retrieve all books in the "Fiction" genre:
select * from books
where genre = 'Fiction'

-- 2) Find books published after the year 1950:
select * from books
where published_year>1950;

-- 3) List all customers from the Canada:
select * from customers
where country='Canada';

-- 4) Show orders placed in November 2023:
select * from orders
where order_date between '2023-11-01' and '2023-11-30';

-- 5) Retrieve the total stock of books available:
select sum(stock) as Total_Stock from books;


-- 6) Retrieve the 2nd most expensive book available:
--** One way:
select book_id, title, author, genre, published_year, price, stock from books
order by price desc 
limit 1 offset 1;

--** Another way:
select max(price) as Second_most_expensive_book from books
where price<(select max(price) from books);



-- 7) Show all customers who ordered more than 1 quantity of a book:
select c.customer_id, c.name, o.quantity 
from customers c
join orders o
on c.customer_id=o.customer_id
where quantity>1;


-- 8) Retrieve all orders where the total amount exceeds $20:
select * from orders
where total_amount>20;


-- 9) List all genres available in the Books table:
-- One way:
select distinct genre from books;

-- Another way:
select genre
from books
group by(genre);


-- 10) List all genre with sold quantity:
select b.genre, sum(o.quantity) as total_sold 
from books b
join orders o
on b.book_id=o.book_id
group by(genre);


-- 11) Find the book with the lowest stock:
--** One way:
select * from books
where stock=(select  min(stock) 
from books
where stock> 0)
limit 1;

--** Another way:
SELECT * FROM Books 
where stock> 0
ORDER BY stock 
LIMIT 1;


-- 12) Calculate the total revenue generated from all orders:
select sum(total_amount) as Revenue from orders;


-- 13) Find the average price of books in the "Fantasy" genre:
select avg(price) as Average_Price
from books
where genre='Fantasy';




-- Advance Questions : 

-- 1) Retrieve the total number of books sold for each genre:
select b.genre, sum(quantity) as total_sold 
from books b
join orders o
on b.book_id=o.book_id
group by(genre);


-- 2) List customers who have placed at least 2 orders:
select c.customer_id, c.name, count(o.order_id) as Order_Count
from orders o
join customers c 
on  c.customer_id=o.customer_id
group by c.customer_id, c.name
having count(o.order_id)>2;


-- 3) Find the most frequently ordered book:
select b.book_id, b.title, count(*) as Order_Count
from orders o
join books b
on b.book_id=o.book_id
group by b.book_id
order by order_count desc limit 1;


-- 4) Show the top 3 most expensive books of 'Fantasy' Genre :
select * from books
where genre='Fantasy'
order by price desc
limit 3;


-- 5) Retrieve the total quantity of books sold by each author:
select b.author, sum(o.quantity) as Total_Sold
from orders o
join books b
on b.book_id=o.book_id
group by b.author;

-- 6) List the cities where customers who spent over $30 are located:
select c.city, sum(o.total_amount) as cost
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.city
having sum(o.total_amount) >30
order by c.city;  


-- 7) Find the customer who spent the most on orders:
select c.customer_id, c.name, sum(o.total_amount) as Total_order
from orders o
join customers c
on c.customer_id=o.customer_id
group by c.customer_id, c.name
order by Total_order desc 
limit 1;


--8) Calculate the stock remaining after fulfilling all orders:
select b.book_id, b.title,b.stock, 
coalesce (sum(o.quantity),0) as total_order, 
b.stock - coalesce (sum(o.quantity),0) as Remaining_Stock
from books b
left join orders o
on b.book_id=o.book_id
group by b.book_id
order by b.book_id;
