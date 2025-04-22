CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    dob DATE,
    gender VARCHAR(10)
);

INSERT INTO Customer VALUES
(1, 'Alice', '1990-03-15', 'Female'),
(2, 'Bob', '1985-06-22', 'Male'),
(3, 'Charlie', '2000-12-02', 'Male'),
(4, 'Diana', '1978-09-30', 'Female'),
(5, 'Eve', '1995-01-10', 'Female');

CREATE TABLE Account (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(50),
    balance DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

INSERT INTO Account VALUES
(101, 1, 'Savings', 3000.00),
(102, 1, 'Checking', 1500.00),
(103, 2, 'Savings', 2500.00),
(104, 3, 'Checking', 1200.00),
(105, 4, 'Savings', 4000.00);

CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_type VARCHAR(50),
    amount DECIMAL(10,2),
    transaction_date DATE,
    FOREIGN KEY (account_id) REFERENCES Account(account_id)
);

INSERT INTO Transactions VALUES
(201, 101, 'Deposit', 1000.00, '2025-03-10'),
(202, 102, 'Withdrawal', 500.00, '2025-03-15'),
(203, 103, 'Deposit', 800.00, '2025-04-01'),
(204, 104, 'Withdrawal', 200.00, '2025-04-05'),
(205, 105, 'Deposit', 700.00, '2025-04-09');

CREATE TABLE Loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_type VARCHAR(50),
    loan_amount DECIMAL(10,2),
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

INSERT INTO Loans VALUES
(301, 1, 'Home', 100000.00, 'Approved'),
(302, 2, 'Auto', 20000.00, 'Approved'),
(303, 3, 'Education', 15000.00, 'Rejected'),
(304, 4, 'Home', 120000.00, 'Approved'),
(305, 5, 'Personal', 5000.00, 'Pending');

-- --Retrieve all transactions along with customer details and account type.
select customer.name, dob, gender, account.account_type, amount, transaction_type,transaction_date from Customer
inner join Account on Account.customer_id = account.customer_id
inner join Transactions on Transactions.account_id=account.account_id;

-- --Find customers who have taken loans but have not made any payments yet.

-- --Get the total balance of each customer, including both savings and checking accounts.
select customer.name,  account_type, balance from account 
inner join customer on account.customer_id=customer.customer_id;

-- --Identify customers who have more than one account.
select customer.name,  count(account_type) as at, GROUP_CONCAT(DISTINCT account_type) AS account_types
from Customer  inner join Account on customer.customer_id=account.customer_id 
group by customer.name having  count(distinct account_type)>1 ;

-- --Retrieve all transactions made in the last 30 days along with customer and account details.
select customer.name, dob, gender, account_type, transaction_date, balance from customer 
inner join Account on Account.customer_id=customer.customer_id
inner join Transactions on Transactions.account_id=account.account_id
where transaction_date>=date_sub(curdate(), interval 30 day);

-- --Find customers who have applied for a loan but were rejected.

select customer.name, loan_type, status,loan_amount from customer inner join loans
on customer.customer_id=loans.customer_id where status="rejected";

-- --Get the top 5 customers with the highest total loan amount.

select customer.name, max(loan_amount) as lam, loan_type from customer inner join loans on customer.customer_id=loans.customer_id
group by customer.name, loan_type order by lam desc limit 5;

-- --Retrieve a list of customers who have never made a withdrawal transaction.
SELECT customer.name FROM customer WHERE customer.customer_id NOT IN (
    SELECT DISTINCT account.customer_id FROM account 
    INNER JOIN transactions ON account.account_id = transactions.account_id
    WHERE transactions.transaction_type = 'Withdrawal'
);

-- --Find the total loan amount issued per loan type.
select sum(loan_amount) as TL, loan_type from loans
group by loan_type;

-- --Identify customers who have both a loan and a savings account.
select customer.name, loan_type, account_type from customer 
inner join loans on customer.customer_id=loans.customer_id
inner join  account on account.customer_id=customer.customer_id where account_type="savings";
