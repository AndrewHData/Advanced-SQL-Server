-----------------------------------------------

------- COMMON TABLE EXPRESSIONS (CTEs) -------

-----------------------------------------------
/*
CTEs - Exercise
For this exercise, assume the CEO of our fictional company decided that the top 10 orders per month are actually outliers that need to be clipped out of our data before doing meaningful analysis.
Further, she would like the sum of sales AND purchases (minus these "outliers") listed side by side, by month.
We've got a query that already does this (see the file "CTEs - Exercise Starter Code.sql" in the resources for this section), but it's messy and hard to read. Re-write it using a CTE so other analysts can read and understand the code.
Hint: You are comparing data from two different sources (sales vs purchases), so you may not be able to re-use a CTE like we did in the video.
*/

/* 
The code 
SELECT
A.OrderMonth,
A.TotalSales,
B.TotalPurchases

FROM (
	SELECT
	OrderMonth,
	TotalSales = SUM(TotalDue)
	FROM (
		SELECT 
		   OrderDate
		  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
		  ,TotalDue
		  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
		FROM Sales.SalesOrderHeader
		) S
	WHERE OrderRank > 10
	GROUP BY OrderMonth
) A

JOIN (
	SELECT
	OrderMonth,
	TotalPurchases = SUM(TotalDue)
	FROM (
		SELECT 
		   OrderDate
		  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
		  ,TotalDue
		  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
		FROM Purchasing.PurchaseOrderHeader
		) P
	WHERE OrderRank > 10
	GROUP BY OrderMonth
) B	ON A.OrderMonth = B.OrderMonth

ORDER BY 1
*/

WITH sales AS(
SELECT
	OrderDate,
	OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
FROM sales.SalesOrderHeader
),

salesminustop10 AS(
SELECT
	OrderMonth,
	SUM(TotalDue) as TotalSales
FROM sales
WHERE OrderRank > 10
GROUP BY OrderMonth
),

purchases AS(
SELECT
	OrderDate,
	OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
	TotalDue,
	OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
FROM Purchasing.PurchaseOrderHeader 
),

purchasesminustop10 AS(
SELECT
	OrderMonth,
	SUM(TotalDue) as TotalPurchases
FROM purchases
WHERE OrderRank > 10
GROUP BY OrderMonth
)

SELECT
	a.OrderMonth,
	TotalSales,
	TotalPurchases
FROM salesminustop10 a
	JOIN purchasesminustop10 b
		ON a.OrderMonth = b.OrderMonth
ORDER BY 1

/*
---------------------------------------
			Recursive CTEs
---------------------------------------

Can be used to make a date table within one query

*/

-- Think of Recursive CTE as divided into three components:
-- 1. The anchor number
-- 2. Recursive number
-- 3. Termination condition

-- Consider the following:
With NumberSeries AS
(
Select 1 AS MyNumber
)
Select 
	MyNumber + 1		
From NumberSeries

-- THe CTE assigns 1 to the variable 'MyNumber' and then the select outside of the CTE adds 1
;

--Recursive version
With NumberSeries AS
(
Select 1 AS MyNumber	-- 1. The anchor number

UNION ALL				-- stacking the below query with itself

SELECT 
	MyNumber + 1		
FROM NumberSeries		-- 2. Recursive number Reference the CTE within the CTE
WHERE MyNumber < 100	-- 3. Termination condition. Number of recursions?
)

Select
MyNumber
FROM NumberSeries

/*  Recursive CTE for Date	*/
-- SQL by default will limit the number of recursions to 100
-- There is a method of overriding that option using OPTION function.

WITH DateSeries AS
(
SELECT CAST('2023-01-01' AS DATE) as MyDate

UNION ALL

SELECT
	DATEADD(DAY,1,MyDate)
FROM DateSeries
WHERE MyDate < CAST('2023-12-31' AS DATE)
)

SELECT
MyDate
FROM DateSeries
OPTION(MAXRECURSION 365)
;

/*
-------------------------------------------------------------------------
Recursive CTEs - Exercises
Exercise 1
Use a recursive CTE to generate a list of all odd numbers between 1 and 100.
Hint: You should be able to do this with just a couple slight tweaks to the code from our first example in the video.
--------------------------------------------------------------------------
*/

With NumberSeries AS
(
Select 1 AS MyNumber	

UNION ALL				

SELECT 
	MyNumber + 2		
FROM NumberSeries		
WHERE MyNumber < 100	  
)

Select
MyNumber
FROM NumberSeries
WHERE MyNumber < 100	  
;

/*
-----------------------------------------------------
Exercise 2
Use a recursive CTE to generate a date series of all FIRST days of the month (1/1/2021, 2/1/2021, etc.)
from 1/1/2020 to 12/1/2029.
Hints:
Use the DATEADD function strategically in your recursive member.
You may also have to modify MAXRECURSION.
-----------------------------------------------------
*/
WITH DateSeries AS
(
SELECT CAST('2021-01-01' AS DATE) as MyDate

UNION ALL

SELECT
	DATEADD(MONTH,1,MyDate)
FROM DateSeries
WHERE MyDate < CAST('2029-12-31' AS DATE)
)

SELECT
MyDate
FROM DateSeries
WHERE MyDate < CAST('2029-12-31' AS DATE)
OPTION(MAXRECURSION 150)
;