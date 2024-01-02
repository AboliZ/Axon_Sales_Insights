                       
                        -- AXON Sales Insights -- 
                        
Use classicmodels;  
show tables;

select * from customers;
describe customers;

/*customers table*/
describe customers;

select * from customers;

# Counting the total number of customers 
select count(customerNumber) as total_customers from customers;

# Retrieving customers without assigned sales representatives

select * from customers where salesRepEmployeeNumber is null;


/*employees table*/
describe employees;
select * from employees;

# Checking for the total number of employees.
select count(employeeNumber) as no_of_Employees from employees;

# Name of the President of the company
select concat(firstName,' ',lastName) as President_Name
from employees
where jobTitle = 'President';

/*offices Table*/

describe offices;

select * from offices;

# Offices by Country
select country , count(officeCode) as Total_Offices from offices 
group by country
order by Total_Offices desc;

/*Orderdetails Table*/
describe Orderdetails;

select * from Orderdetails;

# Total Number of Orders Received
select count(distinct orderNumber) as Total_Orders from orders;

/*Orders Table*/
describe orders;

select * from orders;

#Total Shipped Orders
select status, count(orderNumber) as Total_Orders 
from orders 
where status = 'Shipped';

/*Payments Table*/

describe payments;

select * from payments;
-- Total Amount Recived by year
select sum(amount) Total_Amount from payments;

#Total Amount paid by Customers
select customerName, sum(amount) as Total_Payment
from payments
join customers using(customernumber)
 group by customerNumber
 order by total_payment desc;

#Total Amount Recived by Year 

select year(paymentDate) as Year,
sum(amount) as Total_Amount from payments
group by year;

/*Productlines Table*/
describe productlines;
select  * from productlines;

select productLine  from productLines;

/*Products Table*/
describe products;
select * from products;

# No. Of Products By Product Line
select productLine, count(productCode)as Total_Products
from products
group by productLine;

#Total Vendors 
select count(distinct productVendor) as Total_Vendors from products;

#Top Selling Products

/*  Identify top-selling products based on quantity sold or revenue generated.*/

select productname , count(quantityordered)as Num_of_orders,
sum(quantityordered * priceeach)as total_sales
from products 
join orderdetails using(productcode)
group by productName
order by Num_of_orders desc
limit 5;

/* Write a query to find for every year how many orders shipped */

select year(shippedDate) as Year , count(orderNumber) Total_orders
from orders
where status = 'Shipped'
group by Year
order by Year;

/*Write a query to find number of products ordered by each vendor*/

select p.productVendor, count(od.orderNumber) as Total_Orders from products p  
inner join orderdetails od on od.productCode = p.productCode
group by productVendor
order by Total_Orders desc;

/*Write to query to find the profit margin for each product*/

SELECT od.productCode,p.productName,sum(od.quantityOrdered) as Total_Quanitity_Orderd,
round(avg(p.buyPrice),2) as Avg_Buy_Pice,
round(avg(od.priceEach),2)as Avg_selling_price,
sum(quantityOrdered * priceEach ) as Total_sales,
sum(quantityOrdered * buyPrice) as Total_Cost,
( sum(quantityOrdered * priceEach ) - sum(quantityOrdered * buyPrice) ) as Total_Profit,
concat(round(( ( sum(quantityOrdered * priceEach ) - sum(quantityOrdered * buyPrice) ) / sum(quantityOrdered * priceEach )) * 100,2),' %') as Profit_Margin
FROM orderdetails od
inner join products p on od.productCode = p.productCode
group by od.productCode,p.productName
order by Profit_Margin desc;

/* Creating a view to categorize customer credit status based on their credit limits*/
create view Cust_Credit_Status as 
(

select customerNumber,creditlimit,concat(contactFirstName,contactLastName) as Full_Name,
case 
	when creditLimit < 10000 then 'Low Credit Limit'
    when  creditLimit > 10000 and creditLimit < 70000 then 'Medium Credit Limit'
    when  creditLimit > 70000 then 'High Credit Limit'
    end as Cust_Credit_Status
from customers

);

/*Querying the created view to count customers based on their credit status categories*/

select Cust_Credit_Status, count(customerNumber) as Total_Customers
from Cust_Credit_Status
group by Cust_Credit_Status
order by Total_Customers desc;

# Which country has the largest number of customers?
select country,count(*) as No_of_Customers
from customers
group by country
order by No_of_customers desc
limit 5;

# Which customers are among the top 5 based on the highest number of products ordered?
select customername,count(ordernumber)as Total_orders
from customers
inner join orders using(customernumber)
group by customername
order by Total_orders desc
limit 5;

# What are the top 10 most ordered products based on the total quantity ordered?
select productname,sum(quantityordered)as Total_qty_Ordered
from orderdetails 
inner join Products using(productcode)
group by productname
order by Total_qty_Ordered desc
limit 5;

#Identify the products that haven't been ordered by any customer.
select productname ,quantityinstock from products
where productcode 
not in (select productcode from orderdetails);

#Determine the number of orders placed annually.
select year(orderdate)as Year, count(ordernumber) as Total_orders
from orders
group by year;

#Determine the count of customers assigned to each sales representative. 

select Employeenumber,
concat(firstname," ",lastname)as full_name,
count(customernumber)as Total_customers
from Employees e
inner join 
Customers c on c.salesrepemployeenumber = e.employeenumber
group by 1
order by Total_customers desc;

# Determine the remaining stock for each product at the classic model warehouse.

with cte as 
(select p.productcode,productname,quantityinstock,sum(quantityOrdered)as qty_ordered
from products p 
inner join orderdetails o on o.productcode= p.productcode
group by p.productcode,quantityInStock,productname
order by qty_ordered desc)

select productname,(quantityInStock-(qty_Ordered))as SKU
from cte
order by SKU;

                                     -- END --
