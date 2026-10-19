-- Retail Business Performance Analysis Using SQL
-- 0. DATABASE SETUP

CREATE DATABASE retail_analytics;
USE retail_analytics;


-- 1. TABLE CREATION


CREATE TABLE Customers (
    CustomerID   INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    City         VARCHAR(50),
    JoinDate     DATE
);

CREATE TABLE Products (
    ProductID   INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category    VARCHAR(50),
    Price       DECIMAL(10,2)
);

CREATE TABLE Employees (
    EmployeeID   INT PRIMARY KEY,
    EmployeeName VARCHAR(100) NOT NULL,
    Department   VARCHAR(50),
    HireDate     DATE
);

CREATE TABLE Orders (
    OrderID    INT PRIMARY KEY,
    CustomerID INT,
    OrderDate  DATE,
    EmployeeID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID       INT,
    ProductID     INT,
    Quantity      INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- 2. DATA INSERTION

INSERT INTO Customers (CustomerID, CustomerName, City, JoinDate) VALUES
(101, 'Amit Sharma', 'Delhi', '2022-01-10'),
(102, 'Neha Verma', 'Mumbai', '2022-03-15'),
(103, 'Rahul Mehta', 'Bangalore', '2022-05-01'),
(104, 'Priya Singh', 'Delhi', '2023-01-12'),
(105, 'Karan Patel', 'Ahmedabad', '2023-02-20'),
(106, 'Sneha Reddy', 'Hyderabad', '2023-03-18'),
(107, 'Arjun Nair', 'Kochi', '2023-04-10'),
(108, 'Pooja Gupta', 'Jaipur', '2023-05-05');

select * from Customers;

INSERT INTO Products (ProductID, ProductName, Category, Price) VALUES
(201, 'Laptop', 'Electronics', 55000),
(202, 'Mobile', 'Electronics', 25000),
(203, 'Tablet', 'Electronics', 18000),
(204, 'Headphones', 'Accessories', 2000),
(205, 'Keyboard', 'Accessories', 1500),
(206, 'Mouse', 'Accessories', 800),
(207, 'Monitor', 'Electronics', 12000),
(208, 'Printer', 'Electronics', 9000);

select * from Products;

INSERT INTO Employees (EmployeeID, EmployeeName, Department, HireDate) VALUES
(401, 'Rajesh Kumar', 'Sales', '2020-02-01'),
(402, 'Meena Iyer', 'Sales', '2021-06-15'),
(403, 'Vikram Shah', 'Sales', '2022-09-10'),
(404, 'Anil Gupta', 'Sales', '2023-01-05');

select * from Employees;

INSERT INTO Orders (OrderID, CustomerID, OrderDate, EmployeeID) VALUES
(301, 101, '2023-01-15', 401),
(302, 102, '2023-01-18', 402),
(303, 103, '2023-02-05', 401),
(304, 104, '2023-02-10', 403),
(305, 105, '2023-03-01', 404),
(306, 106, '2023-03-15', 402),
(307, 107, '2023-04-01', 401),
(308, 108, '2023-04-20', 403);

select * from Orders;

INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity) VALUES
(1, 301, 201, 1),
(2, 301, 204, 2),
(3, 302, 202, 1),
(4, 303, 203, 1),
(5, 304, 207, 2),
(6, 305, 205, 3),
(7, 306, 206, 5),
(8, 307, 208, 1),
(9, 308, 201, 1);

select * from OrderDetails;

-- SECTION 1 — JOINS (Basic to Intermediate)

-- Q1: Display all orders with customer names.
SELECT
    o.OrderID,
    o.OrderDate,
    c.CustomerName
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID;


-- Q2: Show product names and quantities for each order.
SELECT
    od.OrderID,
    p.ProductName,
    od.Quantity
FROM OrderDetails od
INNER JOIN Products p ON od.ProductID = p.ProductID
ORDER BY od.OrderID;


-- Q3: Display employee name who handled each order.
SELECT
    o.OrderID,
    o.OrderDate,
    e.EmployeeName
FROM Orders o
INNER JOIN Employees e ON o.EmployeeID = e.EmployeeID;


-- Q4: Show all customers and their orders (including customers without orders).
SELECT
    c.CustomerID,
    c.CustomerName,
    o.OrderID,
    o.OrderDate
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
ORDER BY c.CustomerID;


-- Q5: Display total number of orders handled by each employee.
SELECT
    e.EmployeeID,
    e.EmployeeName,
    COUNT(o.OrderID) AS TotalOrders
FROM Employees e
LEFT JOIN Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.EmployeeName
ORDER BY TotalOrders DESC;

-- SECTION 2 — SUBQUERIES

-- Q6: Find customers who placed more than 1 order.
SELECT CustomerID, CustomerName
FROM Customers
WHERE CustomerID IN (
    SELECT CustomerID
    FROM Orders
    GROUP BY CustomerID
    HAVING COUNT(OrderID) > 1
);
-- Note: no customer has more than 1 order,
-- so this correctly returns an empty result set.


-- Q7: Display products with price higher than the average product price.
SELECT ProductID, ProductName, Category, Price
FROM Products
WHERE Price > (SELECT AVG(Price) FROM Products)
ORDER BY Price DESC;


-- Q8: Find the customer who placed the highest number of orders.
SELECT c.CustomerID, c.CustomerName, COUNT(o.OrderID) AS OrderCount
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName
HAVING COUNT(o.OrderID) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(OrderID) AS cnt
        FROM Orders
        GROUP BY CustomerID
    ) AS OrderCounts
);


-- Q9: Show orders where total quantity is greater than the average quantity
--     (average quantity per order, across all orders).
SELECT
    od.OrderID,
    SUM(od.Quantity) AS TotalQuantity
FROM OrderDetails od
GROUP BY od.OrderID
HAVING SUM(od.Quantity) > (
    SELECT AVG(order_qty.qty)
    FROM (
        SELECT SUM(Quantity) AS qty
        FROM OrderDetails
        GROUP BY OrderID
    ) AS order_qty
);


-- Q10: Find employees who handled more orders than the average employee.
SELECT e.EmployeeID, e.EmployeeName, COUNT(o.OrderID) AS OrderCount
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.EmployeeName
HAVING COUNT(o.OrderID) > (
    SELECT AVG(emp_cnt.cnt)
    FROM (
        SELECT COUNT(OrderID) AS cnt
        FROM Orders
        GROUP BY EmployeeID
    ) AS emp_cnt
);

-- SECTION 3 — WINDOW FUNCTIONS

-- Helper concept used repeatedly below: total sales amount per order
-- = SUM(Quantity * Price) joined through OrderDetails -> Products -> Orders

-- Q11: Assign rank to customers based on total purchase amount.
SELECT
    c.CustomerID,
    c.CustomerName,
    SUM(od.Quantity * p.Price) AS TotalPurchase,
    RANK() OVER (
    ORDER BY SUM(od.Quantity * p.Price) 
    DESC
    ) AS PurchaseRank
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY c.CustomerID, c.CustomerName;


-- Q12: Display cumulative sales amount by order date.
SELECT
    o.OrderDate,
    o.OrderID,
    SUM(od.Quantity * p.Price) AS OrderAmount,
    SUM(SUM(od.Quantity * p.Price)) OVER (ORDER BY o.OrderDate, o.OrderID) AS CumulativeSales
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY o.OrderDate, o.OrderID
ORDER BY o.OrderDate, o.OrderID;


-- Q13: Display running total of sales for each employee.
SELECT
    e.EmployeeID,
    e.EmployeeName,
    o.OrderDate,
    o.OrderID,
    SUM(od.Quantity * p.Price) AS OrderAmount,
    SUM(SUM(od.Quantity * p.Price)) OVER (
        PARTITION BY e.EmployeeID
        ORDER BY o.OrderDate, o.OrderID
    ) AS RunningTotal
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY e.EmployeeID, e.EmployeeName, o.OrderDate, o.OrderID
ORDER BY e.EmployeeID, o.OrderDate;


-- Q14: Find the highest priced product in each category.
SELECT ProductID, ProductName, Category, Price
FROM (
    SELECT
        ProductID,
        ProductName,
        Category,
        Price,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Price DESC) AS rn
    FROM Products
) ranked
WHERE rn = 1;

-- OPTIONAL BONUS TASKS (Advanced — if you want to challenge stronger students)

-- Q15: Find customers who never placed an order.
SELECT c.CustomerID, c.CustomerName
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;


-- Q16: Find the second highest selling product (by total quantity sold).
SELECT ProductID, ProductName, TotalSold
FROM (
    SELECT
        p.ProductID,
        p.ProductName,
        SUM(od.Quantity) AS TotalSold,
        DENSE_RANK() OVER (ORDER BY SUM(od.Quantity) DESC) AS SalesRank
    FROM Products p
    JOIN OrderDetails od ON p.ProductID = od.ProductID
    GROUP BY p.ProductID, p.ProductName
) ranked
WHERE SalesRank = 2;


-- Q17: Identify duplicate orders placed on the same day (by the same customer).
SELECT CustomerID, OrderDate, COUNT(OrderID) AS OrdersOnSameDay
FROM Orders
GROUP BY CustomerID, OrderDate
HAVING COUNT(OrderID) > 1;
-- Note: with this sample data, no customer places more than one order
-- on the same day, so this returns an empty result set. To see it work,
-- try adding a second order for CustomerID 101 on '2023-01-15'.


-- Q18: Calculate monthly sales growth percentage.
WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(o.OrderDate, '%Y-%m') AS SalesMonth,
        SUM(od.Quantity * p.Price) AS TotalSales
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY DATE_FORMAT(o.OrderDate, '%Y-%m')
)
SELECT
    SalesMonth,
    TotalSales,
    LAG(TotalSales) OVER (ORDER BY SalesMonth) AS PrevMonthSales,
    ROUND(
        (TotalSales - LAG(TotalSales) OVER (ORDER BY SalesMonth))
        / LAG(TotalSales) OVER (ORDER BY SalesMonth) * 100
    , 2) AS GrowthPercent
FROM MonthlySales
ORDER BY SalesMonth;


-- Q19: Find the top performing employee each month (by total sales amount).
WITH MonthlyEmployeeSales AS (
    SELECT
        e.EmployeeID,
        e.EmployeeName,
        DATE_FORMAT(o.OrderDate, '%Y-%m') AS SalesMonth,
        SUM(od.Quantity * p.Price) AS TotalSales
    FROM Employees e
    JOIN Orders o ON e.EmployeeID = o.EmployeeID
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY e.EmployeeID, e.EmployeeName, DATE_FORMAT(o.OrderDate, '%Y-%m')
),
RankedEmployeeSales AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY SalesMonth ORDER BY TotalSales DESC) AS MonthRank
    FROM MonthlyEmployeeSales
)
SELECT EmployeeID, EmployeeName, SalesMonth, TotalSales
FROM RankedEmployeeSales
WHERE MonthRank = 1
ORDER BY SalesMonth;