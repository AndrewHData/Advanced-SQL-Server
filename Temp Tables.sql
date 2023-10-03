--------------------------------------------------
------------------	TEMP TABLES	------------------
--------------------------------------------------

/* 
-- Kind of like a more flexible version of CTEs 
Unlike CTEs which are limited to the one query,
temp tables are available while the session is open!
---------------------------
-- To create the temptable:
SELECT
	*
INTO #temptable		<-make sure we use the pound symbol # after 'INTO'
FROM table

---------------------------
-- To reference it again
SELECT
	*
FROM #temptable


---------------------------
-- Make sure to drop the #temptable at the end of your query
This is because the temp tables stay in memory.
*/

/*
Temp Tables - Exercises
Exercise
Refactor your solution to the exercise from the section on CTEs (average sales/purchases minus top 10) using temp tables in place of CTEs.
*/

-- Sales
SELECT
	OrderDate,
	OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
INTO #sales
FROM sales.SalesOrderHeader

-------------------------------
-- Sales minus top 10
SELECT
	OrderMonth,
	SUM(TotalDue) as TotalSales
INTO #salesminustop10
FROM #sales
WHERE OrderRank > 10
GROUP BY OrderMonth

-------------------------------
-- Purchases
SELECT
	OrderDate,
	OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
INTO #purchases
FROM Purchasing.PurchaseOrderHeader 

-------------------------------
--Purchases minus Top 10
SELECT
	OrderMonth,
	SUM(TotalDue) as TotalPurchases
INTO #purchasesminustop10
FROM #purchases
WHERE OrderRank > 10
GROUP BY OrderMonth

-------------------------------
-- Main query
SELECT
	a.OrderMonth,
	TotalSales,
	TotalPurchases
FROM #salesminustop10 a
	JOIN #purchasesminustop10 b
		ON a.OrderMonth = b.OrderMonth
ORDER BY 1

-------------------------------
-- Dropping the temp tables
DROP TABLE #sales
DROP TABLE #salesminustop10
DROP TABLE #purchases
DROP TABLE #purchasesminustop10
-------------------------------

--------------------------------------------------
--------------- CREATE AND INSERT ----------------
--------------------------------------------------

/* The idea is to create a temp table with no data, insert data. This gives us more flexibility over the columns etc. */

CREATE TABLE #sales
(
	OrderDate DATE,
	OrderMonth DATE,
	TotalDue MONEY,
	OrderRank INT
)

INSERT INTO #sales

(
	OrderDate,
	OrderMonth,
	TotalDue,
	OrderRank
)

SELECT
	OrderDate,
	OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
FROM sales.SalesOrderHeader
--------

SELECT * FROM #sales ORDER BY 1
--------
-- Drop the table
DROP TABLE #sales
;

-----------------------------------

/* Creating a top 10 sales table. Note no parentheses around the bottom query and it still works */
CREATE TABLE #top10sales
(
OrderMonth DATE,
Top10Total MONEY
)

INSERT INTO #top10sales

SELECT
	OrderMonth,
	Top10Total = SUM(TotalDue)
FROM #sales
WHERE OrderRank <= 10
GROUP BY OrderMonth

Select * from #top10sales

-------------------------------------------

/*
CREATE and INSERT - Exercise
Exercise
Rewrite your solution from last video's exercise using CREATE and INSERT instead of SELECT INTO.
*/

-- Sales table

CREATE TABLE #sales
(
	OrderDate DATE,
	OrderMonth DATE,
	TotalDue MONEY,
	OrderRank INT
)

INSERT INTO #sales

SELECT
	OrderDate,
	OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
FROM sales.SalesOrderHeader


SELECT * FROM #sales ORDER BY 1
;
-------------------------------
-- Sales minus top 10
CREATE TABLE #salesminustop10
(
	OrderMonth DATE,
	TotalSales MONEY
)

INSERT INTO #salesminustop10

SELECT
	OrderMonth,
	SUM(TotalDue) as TotalSales
FROM #sales
WHERE OrderRank > 10
GROUP BY OrderMonth


SELECT * FROM #salesminustop10 ORDER BY 1

-------------------------------
-- Purchases
CREATE TABLE #purchases
(
	OrderDate DATE,
	OrderMonth DATE,
	TotalDue MONEY,
	OrderRank INT
)

INSERT INTO #purchases

SELECT
	OrderDate,
	OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
FROM Purchasing.PurchaseOrderHeader 

-------------------------------
--Purchases minus Top 10
CREATE TABLE #purchasesminustop10
(
	OrderMonth DATE,
	TotalPurchases MONEY
)

INSERT INTO #purchasesminustop10

SELECT
	OrderMonth,
	SUM(TotalDue) as TotalPurchases
FROM #purchases
WHERE OrderRank > 10
GROUP BY OrderMonth

-------------------------------
-- Main query
SELECT
	a.OrderMonth,
	TotalSales,
	TotalPurchases
FROM #salesminustop10 a
	JOIN #purchasesminustop10 b
		ON a.OrderMonth = b.OrderMonth
ORDER BY 1
-------------------------------
-- Dropping the temp tables
DROP TABLE #sales
DROP TABLE #salesminustop10
DROP TABLE #purchases
DROP TABLE #purchasesminustop10
-------------------------------

--------------------------------------------------
-------------------- TRUNCATE --------------------
--------------------------------------------------

/*
Truncate empties the table values without affecting the structure of the table. 
The idea is to clear a table and then reuse it.
This allows us to to reduce the amount of repetition and also use templates. 

SYNTAX
TRUNCATE TABLE #tablename

*/

/* 
TRUNCATE - Exercise

Leverage TRUNCATE to re-use temp tables in your solution to "CREATE and INSERT" exercise.

Hints:
1.)
Instead of joining two tables in your final SELECT (#AvgSalesMinusTop10 and #AvgPurchasesMinusTop10), you will most likely need to join a single consolidated query to itself.
The join will work much like before, but you will need to add a new wrinkle that filters each copy of the table based on whether it contains purchase or sales data.
For whatever copy of the table you put after the FROM, include the filtering criteria in the WHERE clause.
For the other copy of the table, apply the filtering criteria directly in the join.
These different "cuts" of the same table will accomplish the same thing as two distinct tables did previously.

2.)
In the SELECT clause of your final query, you will probably need to apply aliases to a couple of field names
to distinguish total sales from total purchases. Make sure you apply the appropriate alias to the field
from the appropriate copy of the table.
*/


-- Create an Orders table using the Sales table from previous CREATE INTO
--
/* Sales table from previous CREATE INTO exercise

CREATE TABLE #sales
(
	OrderDate DATE,
	OrderMonth DATE,
	TotalDue MONEY,
	OrderRank INT
)

INSERT INTO #sales

SELECT
	OrderDate,
	OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
FROM sales.SalesOrderHeader

*/
--Below is the exercise

-- Putting in the sales data into an #orders table
CREATE TABLE #orders
(
	OrderDate DATE,
	OrderMonth DATE,
	TotalDue MONEY,
	OrderRank INT
)

INSERT INTO #orders

SELECT
	OrderDate,
	OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
FROM sales.SalesOrderHeader
;
-- Use the below to check if the table loaded
select * from #orders order by 1
;
-- After that we create an #ordersminustop10 table
-- We can use the previous exercise as a template, with some changes.

/*
-- Below is the sales minus top 10 table 
CREATE TABLE #salesminustop10
(
	OrderMonth DATE,
	TotalSales MONEY
)

INSERT INTO #salesminustop10

SELECT
	OrderMonth,
	SUM(TotalDue) as TotalSales
FROM #sales
WHERE OrderRank > 10
GROUP BY OrderMonth
*/

-- Create the orders minustop10 table
CREATE TABLE #ordersminustop10
(
	OrderMonth DATE,
	order_type VARCHAR(32), -- add the order_type column to differentiate Sales and Puchase. Like the formula tool and just having string 'Sales'
	total_order MONEY
)

-- Then we insert the orders minus the top 10 using the below
INSERT INTO #ordersminustop10

SELECT
	OrderMonth,
	order_type = 'Sales',  -- hardcode the word 'Sales'. It's like the formula tool where you make a new column.
	SUM(TotalDue) as total_order
FROM #orders
WHERE OrderRank > 10
GROUP BY OrderMonth
;

-- After inserting the Sales data from the #orders table into the #ordersminustop 10 , we truncate the #orders table and insert the purchase data
TRUNCATE TABLE #orders
;
-- check that we truncated the #orders table
select * from #orders
;
-- Insert the purchase data into the #orders table
INSERT INTO #orders

SELECT
	OrderDate,
	OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
FROM Purchasing.PurchaseOrderHeader 
;

-- check that the purchases have populated the #orders table
select * from #orders
;
-- Insert the purchases into the ordersminustop10
INSERT INTO #ordersminustop10

SELECT
	OrderMonth,
	order_type = 'Purchases',  -- hardcode the word 'Purchases'. It's like the formula tool where you make a new column, but instead union it.
	SUM(TotalDue) as total_order
FROM #orders
WHERE OrderRank > 10
GROUP BY OrderMonth
;

-- check the table
select * from #ordersminustop10
;

-- Now for the main query
SELECT
	a.OrderMonth,
	TotalSales = a.total_order,
	TotalPurchases = b.total_order
FROM #ordersminustop10 a
	JOIN #ordersminustop10 b
		ON a.OrderMonth = b.OrderMonth
		AND b.order_type = 'Purchases'
WHERE a.order_type = 'Sales'
ORDER BY 1,2
;
-- dropping both tables
DROP TABLE #orders,#ordersminustop10
-- checking if they've been dropped. Should be a red underline and SSMS does not recognise the table
select * from #orders
select * from #ordersminustop10
;

--------------------------------------------------
--------------------- UPDATE ---------------------
--------------------------------------------------

/*
SYNTAX
After making a select blah blah from tablename
UPDATE #table
SET
	alias_new_field_1 = calculation,
	alias_new_field_2 = calculation


This is a another way to insert data into tables.
Update works on every row for every column after SET

;

*/

/*
What if we want to update one field based on another field? 

This is where it's important to update one field first, and then the one that needs that first field.

Think of it like CTEs

*/

-----------------------------
/*
Exercise
-----------------
Using the code in the "Update - Exercise Starter Code.sql" file in the resources for this section (which is the same as the example presented in the video), update the value in the "OrderSubcategory" field as follows:
The value in the field should consist of the following string values concatenated together in this order:
- The value in the "OrderCategory" field
- A space
- A hyphen
- Another space
- The value in the "OrderAmtBucket" field

The values in the field should look like the following:

*/
CREATE TABLE #SalesOrders
(
 SalesOrderID INT,
 OrderDate DATE,
 TaxAmt MONEY,
 Freight MONEY,
 TotalDue MONEY,
 TaxFreightPercent FLOAT,
 TaxFreightBucket VARCHAR(32),
 OrderAmtBucket VARCHAR(32),
 OrderCategory VARCHAR(32),
 OrderSubcategory VARCHAR(32)
)

INSERT INTO #SalesOrders
(
 SalesOrderID,
 OrderDate,
 TaxAmt,
 Freight,
 TotalDue,
 OrderCategory
)

SELECT
 SalesOrderID,
 OrderDate,
 TaxAmt,
 Freight,
 TotalDue,
 OrderCategory = 'Non-holiday Order'

FROM [Sales].[SalesOrderHeader]

WHERE YEAR(OrderDate) = 2013

-- Check the created #Sales Order Table
SELECT * FROM #SalesOrders
;

UPDATE #SalesOrders
SET 
TaxFreightPercent = (TaxAmt + Freight)/TotalDue,
OrderAmtBucket = 
	CASE
		WHEN TotalDue < 100 THEN 'Small'
		WHEN TotalDue < 1000 THEN 'Medium'
		ELSE 'Large'
	END


UPDATE #SalesOrders
SET TaxFreightBucket = 
	CASE
		WHEN TaxFreightPercent < 0.1 THEN 'Small'
		WHEN TaxFreightPercent < 0.2 THEN 'Medium'
		ELSE 'Large'
	END


UPDATE #SalesOrders
SET  OrderCategory = 'Holiday'
FROM #SalesOrders
WHERE DATEPART(quarter,OrderDate) = 4

--Your code below this line:

UPDATE #SalesOrders
SET OrderSubcategory = [OrderCategory] + ' - ' + [OrderAmtBucket]
FROM #SalesOrders

SELECT * FROM #SalesOrders
;

DROP TABLE #SalesOrders
--------------------------------------------------
--------------------- DELETE ---------------------
--------------------------------------------------

/*

It deletes all rows that aren't specified in the WHERE clause under it.
It is a more precise method of removing rows
*/


