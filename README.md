DROP DATABASE IF EXISTS retail_analytics;
# Retail Sales & Customer Analytics (SQL)

## Overview
A SQL project that analyses retail business performance. It creates a 
database with sample data and answers 19 business questions on customers, 
products, orders and employees.

## Database Schema
| Table | Description |
|---|---|
| Customers | Customer name, city, join date |
| Products | Product name, category, price |
| Employees | Employee name, department, hire date |
| Orders | Order date, customer and employee who handled it |
| OrderDetails | Products and quantities in each order |

Orders link to Customers and Employees, and OrderDetails link to Orders 
and Products, using foreign keys.

## Queries Covered
**Section 1: Joins (Q1-Q5)**
- Orders with customer names, products per order, employee per order
- Customers with and without orders (LEFT JOIN)
- Total orders handled by each employee

**Section 2: Subqueries (Q6-Q10)**
- Customers with more than one order
- Products priced above average
- Customer with the most orders
- Orders and employees above the average

**Section 3: Window Functions (Q11-Q14)**
- Customer ranking by total purchase amount (RANK)
- Cumulative sales by order date
- Running total of sales per employee
- Highest priced product in each category (ROW_NUMBER)

**Bonus Tasks (Q15-Q19)**
- Customers who never placed an order
- Second highest selling product (DENSE_RANK)
- Duplicate orders on the same day
- Monthly sales growth percentage (CTE and LAG)
- Top performing employee each month (CTEs and RANK)

## Skills Demonstrated
- INNER JOIN and LEFT JOIN across multiple tables
- Subqueries with IN, HAVING and nested aggregates
- Window functions: RANK, DENSE_RANK, ROW_NUMBER, LAG, running totals
- Common Table Expressions (CTEs)
- Primary and foreign keys

## Notes and Assumptions
- There is no historical price column, so revenue is calculated as 
  Quantity × current product Price.
- Some queries (Q6, Q15 and Q17) return empty results with this sample 
  data, because no customer has more than one order, every customer has 
  placed an order, and no one ordered twice on the same day. The queries 
  themselves are correct.

## How to Run
Open MySQL Workbench (or any MySQL client), load 
`retail_sales_customer_analytics.sql` and run the script.

## Tools
MySQL
