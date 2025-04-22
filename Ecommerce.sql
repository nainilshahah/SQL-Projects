-- 1. Customers Table
CREATE TABLE Customers_1 (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

INSERT INTO Customers_1 VALUES
(1, 'Alice Smith', 'alice@example.com'),
(2, 'Bob Johnson', 'bob@example.com'),
(3, 'Carol Lee', 'carol@example.com'),
(4, 'David Kim', 'david@example.com'),
(5, 'Eve Brown', 'eve@example.com');

-- 2. Categories Table
CREATE TABLE Categories_1 (
    category_id INT PRIMARY KEY,
    name VARCHAR(100)
);

INSERT INTO Categories_1 VALUES
(1, 'Electronics'),
(2, 'Furniture'),
(3, 'Stationery');

-- 3. Products Table
CREATE TABLE Products_12 (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category_id INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (category_id) REFERENCES Categories_1(category_id)
);

INSERT INTO Products_12 VALUES
(1, 'Laptop', 1, 999.99),
(2, 'Smartphone', 1, 599.99),
(3, 'Desk Chair', 2, 199.99),
(4, 'Headphones', 1, 149.99),
(5, 'Pen Set', 3, 9.99);

-- 4. Orders Table
CREATE TABLE Orders_1 (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers_1(customer_id)
);

INSERT INTO Orders_1 VALUES
(101, 1, '2024-03-01'),
(102, 2, '2024-03-05'),
(103, 1, '2024-03-10'),
(104, 3, '2024-03-11'),
(105, 4, '2024-03-20'),
(106, 5, '2024-03-22'),
(107, 2, '2024-03-25');

-- 5. Order_Items Table (with customer_id)
CREATE TABLE Order_Items1 (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    customer_id INT,
    FOREIGN KEY (order_id) REFERENCES Orders_1(order_id),
    FOREIGN KEY (product_id) REFERENCES Products_12(product_id),
    FOREIGN KEY (customer_id) REFERENCES Customers_1(customer_id)
);

-- Match customer_id to orders manually
INSERT INTO Order_Items1 VALUES
(1, 101, 1, 1, 1),
(2, 101, 4, 2, 1),
(3, 102, 2, 1, 2),
(4, 103, 3, 1, 1),
(5, 104, 1, 1, 3),
(6, 105, 3, 1, 4),
(7, 107, 2, 1, 2);

-- 6. Payments Table
CREATE TABLE Payments_1 (
    payment_id INT PRIMARY KEY,
    order_id INT,
    amount DECIMAL(10, 2),
    status VARCHAR(20), -- 'Completed', 'Pending', 'Declined'
    payment_method VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES Orders_1(order_id)
);

INSERT INTO Payments_1 VALUES
(1001, 101, 1299.97, 'Completed', 'Credit Card'),
(1002, 102, 599.99, 'Completed', 'PayPal'),
(1003, 103, 199.99, 'Pending', 'Credit Card'),
(1004, 104, 999.99, 'Declined', 'Bank Transfer'),
(1005, 105, 199.99, 'Completed', 'Credit Card'),
-- No payment for order 106
(1006, 107, 599.99, 'Completed', 'PayPal');

-- --1. Retrieve all orders with customer details and payment status.
select orders1.order_id, order_date, email, customers1.name, status from orders1 
left join payments on orders1.order_id = payments.order_id
inner join Customers1 on Customers1.customer_id =orders1.Customer_id;
 
-- --2. Find the total amount spent by each customer, including only completed payments.
select name, sum(amount) as amt from Customers_1 
inner join  orders_1 on Customers_1.customer_id = orders_1.customer_id
inner join payments_1 on Payments_1.order_id = Orders_1.order_id
where Payments_1.status = "completed" group by name;

-- --3. List products that have never been ordered.
select products_12.name from products_12 left join Order_Items1
on products_12.product_id= Order_Items1.product_id
WHERE Order_Items1.order_id IS NULL;

-- --4. Get the top 5 customers who have placed the most orders, including their total spending.
select name, count(Orders_1.order_id) as No_ord,sum(amount) as spending from customers_1
inner join  Orders_1 on customers_1.customer_id = Orders_1.customer_id
left join payments_1 on Orders_1.order_id=payments_1.order_id where status="completed"
group by name order by No_ord desc limit 5;

-- --5. Retrieve all orders along with product names and category names.
select order_id, Products_12.name, Categories_1.name from Products_12 
inner join  Order_Items1 on  Order_Items1.product_id   =  Products_12.product_id
inner join Categories_1 on Categories_1.category_id = Products_12.category_id;

-- --6. Find customers who have placed orders but have not made a payment yet.
select Customers_1.name,  Payments_1.status, Orders_1.order_id from  Customers_1 
inner join Orders_1 on  Customers_1.customer_id = Orders_1.customer_id
left join payments_1 on payments_1.order_id = Orders_1.order_id 
where Payments_1.status is null or Payments_1.status IN ('Pending', 'Declined');

-- --7. Get a summary of total sales per product category.--------(why cant we use amount directly)
select products_12.name, Categories_1.name, sum(Products_12.price * Order_Items1.quantity) as ts from categories_1 
inner join Products_12 on Products_12.category_id=categories_1.category_id
inner join Order_Items1 on Order_Items1.product_id =Products_12.product_id  
inner join Payments_1 on Order_Items1.order_id=Payments_1.order_id
GROUP BY Products_12.name, Categories_1.name
ORDER BY ts DESC;

-- --8. Retrieve the latest order details along with the customer and payment method.
select Orders_1.order_id, order_date, customers_1.name, sum(amount) as spending,  payment_method, status from 
Orders_1 inner join customers_1 on Orders_1.customer_id =customers_1.customer_id 
inner join Payments_1 on  Payments_1.order_id = Orders_1.order_id 
group by orders_1.order_id, order_date, customers_1.name, payment_method, status order by order_date desc;

-- --9. Find orders where the payment was declined.
select Orders_1.order_id, order_date, customers_1.name, status
from Orders_1 inner join customers_1 on Orders_1.customer_id =customers_1.customer_id 
inner join Payments_1 on  Payments_1.order_id = Orders_1.order_id 
where status ="declined";

-- --10. Identify customers who have ordered at least 3 different product categories.
select (customers_1.name) as cname, count(distinct Categories_1.category_id) as total_cat from Products_12 
inner join Categories_1 on  Categories_1.category_id=Products_12.category_id 
inner join Order_Items1 on Order_Items1.product_id=products_12.product_id
inner join   Customers_1 on Customers_1.customer_id = order_Items1.customer_id
group by cname having total_cat>=3; 