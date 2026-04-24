create database Reatail_store;
use Reatail_store;

-- START CREATING TABLE  
create table customers
( customer_id int primary key auto_increment,
name  varchar(100) not null,
 email varchar(100) unique not null,
 phone varchar(15),
 create_at datetime default current_timestamp    -- 
											);  --
                                            alter table customers rename column create_at to created_at;
											
create table product
(product_id int primary key auto_increment,
name varchar(100) not null,
category varchar(50) not null,
price decimal(10,2) not null check(price > 0),
stock_quantity int not null default 0,
added_on datetime default current_timestamp);


alter  table  product  rename to products;


create table orders 
(order_id int primary key auto_increment,
customer_id int,
order_date datetime default current_timestamp,
status varchar(20) default 'pending',
total_amount decimal(10,2),
foreign key(customer_id) references customers(customer_id));


create table order_items
(order_item_id int primary key auto_increment,
order_id int,
product_id int,
quantity int not null check(quantity > 0),
item_price decimal (10,2)not null,
foreign key(order_id) references orders(order_id),
foreign key (product_id) references products(product_id));   

create table payments
(payment_id int primary key auto_increment,
order_id int,
payment_date datetime default current_timestamp,
amount_paid decimal(10,2)not null check(amount_paid > 0),
method varchar(20) not null,
foreign key(order_id)references orders(order_id));

create table product_review
(review_id int primary key auto_increment,
product_id int,
customer_id int,
rating int not null ,
review_date datetime default current_timestamp,
foreign key(product_id)references product(product_id),
foreign key(customer_id)references customers(customer_id));

alter table product_review rename to product_reviews;
alter table product_reviews add  review_text text;
 
           --  level 1  BASIC 
           
-- 1.  Retrive customer names and emails for marketing 
  select name,email from customers;
  
  -- 2. Veiw  complete  product  catalog with all abailable  details 
  select*from products;
  
  -- 3. List  all unique  product categories 
  select  distinct  category from products;
  
  -- 4. show all products price above 1,000 
  select name,price from products where price > 1000;
  
  -- 5. Display products within  a mid-range  price bracket (2000 to 5000)
  select *from products where price between 2000 and 5000;
  
  -- 6. fetch data  for specific  customer IDs (e.g from loyalty program list)
  select * from customers where customer_id in(1,2,5,6,9,10,12,15,17,19);
  
  -- 7. Identify customers whose names start with the letter ‘A’
  select *from customers where name  like 'A%';
  
  -- 8. List electronics products priced under ₹3,000
  select*from products where category='Electronics'and price < 3000;
  
  -- 9. Display product names and prices in descending order of price
  select name,price from products order by price desc;
  
  -- 10. Display product names and prices, sorted by price and then by name
  select name,price from products order by price asc, name asc ;
  
  
  --  level 2 Filtering and Formatting
  
  -- 1. Retrieve orders where customer information is missing (possibly due to data migration or
-- deletion)
select*from customers where customer_id is null;

 -- 2. Display customer names and emails using column aliases for frontend readability
 select name as customer_name ,email as c_emails from customers;
 
 -- 3. Calculate total value per item ordered by multiplying quantity and item price
 select sum(quantity*item_price) as total_revenue from order_items;
 
 -- 4. Combine customer name and phone number in a single column
 select concat(name,' : ',phone)as customer_contact from customers;
 
 -- 5. Extract only the date part from order timestamps for date-wise reporting
 select order_id ,date(order_date) as date  from orders;
 
 -- 6. List products that do not have any stock left
 select *from products  where stock_quantity=0;
 
 -- 7. List the number of products sold per category
 select  category,count(*) as sold_percategory from products group by category;
 
 -- 8. Find the average item price per category
  select  category,avg(price) as avg_percategory from products group by category;

-- 9. Show number of orders placed per day
    select  status ,count(order_date) as order_placed  from orders  where status= 'delivered' group by status ;

-- 10. List total payments received per payment method
select method , sum(amount_paid) as total_payment  from payments group by method;


                -- Level 4: Multi-Table Queries (JOINS)
                
-- 1. Retrieve order details along with the customer name (INNER JOIN)     
select order_id,name from orders  inner join customers  on  orders.customer_id=customers.customer_id;

-- 2. Get list of products that have been sold (INNER JOIN with order_items)
SELECT status,order_item_id from orders inner join order_items on orders.order_id=order_items.order_id where status='delivered';

-- 3. List all orders with their payment method (INNER JOIN)
SELECT order_item_id,method from order_items inner join payments on order_items.order_id=payments.order_id ;

-- 4. Get list of customers and their orders (LEFT JOIN)
select name, order_id from customers left join orders on customers.customer_id= orders.customer_id;

-- 5. List all products along with order item quantity (LEFT JOIN)
select name, quantity from products left join order_items on products.product_id= order_items.product_id;

-- 6. List all payments including those with no matching orders (RIGHT JOIN)
select p.payment_id, o.order_id from payments as p  right join orders as o on p.order_id= o.order_id;

-- 7. Combine data from three tables: customer, order, and payment
select c.customer_id,c.name,o.order_id,o.order_date,p.payment_id,p.payment_date from customers c 
inner join  orders o on c.customer_id=o.customer_id 
inner join payments p on o.order_id= p.order_id;


                   -- Level 5: Subqueries (Inner Queries)
                   
				
                   -- 1. List all products priced above the average product price
                   select*from products where price >(select avg(price) from products);
                   
                   -- 2. Find customers who have placed at least one order
                   select customer_id, name from customers where customer_id  IN (select  customer_id from orders);
                   
                   -- 3. Show orders whose total amount is above the average for that customer
                   select *from orders where total_amount >(select avg(total_amount) from orders);
                   
                   -- 4. Display customers who haven’t placed any orders
                   select name,customer_id from customers where customer_id not in (select customer_id from orders);
                   
                   -- 5. Show products that were never ordered

                   -- 6. Show highest value order per customer
                   select customer_id ,max(total_amount) as high_value_customer from orders group by customer_id;
                   
                   -- 7. Highest Order Per Customer (Including Names)
                   select c.name ,o.customer_id,max(total_amount) as higest_order_percustomer from customers c join orders o on   c.customer_id =o.customer_id group by c.name , o.customer_id ;
                   
                   
                                        -- Level 6: Set Operations
                                   
                                   
			--  1. List all customers who have either placed an order or written a product review
			select name,customer_id from customers where customer_id
            in (select customer_id from orders union select customer_id from product_reviews);
            
            -- 2. List all customers who have placed an order as well as reviewed a product [intersect not
            -- supported]
            
			select name,customer_id from customers where customer_id  in(select customer_id from orders) and customer_id in ( select customer_id from product_reviews);
            
            
            