-----------------------------------------------------
-----------------  PROGRAMMING SQL ------------------
-----------------------------------------------------

/*

This section will covering things that happen to also appear in other programming languages like Python and Javascript

*/

-----------------------------------------------------
-----------------  VARIABLES PT 1  ------------------
-----------------------------------------------------

/*

Variable is a placeholder for value or number of values

Variable is indicated with @ at the start

See example for syntax

*/

-- Method of using Variable
DECLARE @MyVar INT

SET @MyVar = 11

SELECT @MyVar --You have to highlight the DECLARE and SET parts when SELECTing the variable


-- Condensed methodof using Variable (removes the SET part)
DECLARE @MyVar INT = 11

SELECT @MyVar
---------------------------------------------------------------------------------------------------
-- Use case for variable --
-- Consider the select query below
SELECT 
* 
FROM Production.Product
WHERE ListPrice >= 1000
;

-- If we know the Min Price we are after is 1000, we can use a variable to achieve the same thing
DECLARE @MinPrice MONEY 

SET @MinPrice = 1000

SELECT 
*
FROM Production.Product
WHERE ListPrice >= @MinPrice
;

-- We can assign sub-queries to variables. This will help with avoiding repetition and improve readability 
-- In programming there is a principle called DRY: Don't Repeat Yourself.

-- Example of assigning a sub-query to a variable
-- Consider the below SQL query that uses the same sub-query multiple times
SELECT
    ProductID,
    Name,
    StandardCost,
    ListPrice,
    AvgListPrice = (SELECT AVG(ListPrice) FROM AdventureWorks2017.Production.Product),
    AvgListPriceDiff = ListPrice - (SELECT AVG(ListPrice) FROM AdventureWorks2017.Production.Product)
FROM AdventureWorks2017.Production.Product

WHERE ListPrice > (SELECT AVG(ListPrice) FROM AdventureWorks2017.Production.Product)

ORDER BY ListPrice ASC

-- We can refactor (change) it by assigning the sub-query to a variable
DECLARE @AvgListPrice MONEY

SET @AvgListPrice = (SELECT AVG(ListPrice) FROM AdventureWorks2017.Production.Product)      --Make sure the subquery is wrapped in      parentheses
SELECT
    ProductID,
    Name,
    StandardCost,
    ListPrice,
    AvgListPrice = @AvgListPrice,
    AvgListPriceDiff = ListPrice - @AvgListPrice
FROM AdventureWorks2017.Production.Product

WHERE ListPrice > @AvgListPrice
ORDER BY ListPrice ASC

/*
Variables - Exercise 1
Exercise
Refactor the provided code (see the "Variables Part 1 - Exercise Starter Code.sql" in the Resources for this section) to utilize variables instead of embedded scalar subqueries.
*/


--Starter code:
SELECT
	   BusinessEntityID
      ,JobTitle
      ,VacationHours
	  ,MaxVacationHours = (SELECT MAX(VacationHours) FROM AdventureWorks2017.HumanResources.Employee)
	  ,PercentOfMaxVacationHours = (VacationHours * 1.0) / (SELECT MAX(VacationHours) FROM AdventureWorks2017.HumanResources.Employee)

FROM AdventureWorks2017.HumanResources.Employee

WHERE (VacationHours * 1.0) / (SELECT MAX(VacationHours) FROM AdventureWorks2017.HumanResources.Employee) >= 0.8
;


-- Refactored code
DECLARE @MaxVacationHours FLOAT

SET @MaxVacationHours = (SELECT MAX(VacationHours) FROM AdventureWorks2017.HumanResources.Employee)

SELECT
	   BusinessEntityID
      ,JobTitle
      ,VacationHours
	  ,MaxVacationHours = @MaxVacationHours
	  ,PercentOfMaxVacationHours = VacationHours / @MaxVacationHours

FROM AdventureWorks2017.HumanResources.Employee

WHERE VacationHours / @MaxVacationHours >= 0.8
;


-----------------------------------------------------
-----------------  VARIABLES PT 2  ------------------
-----------------------------------------------------

/*
Variables can refer to each other.

In the example, we'll look at today's date and the beginning of today's month
*/

--Example
------------------------------------------------------
-- Just quickly creating a temp calendar table so we can test out the variables

--Create the Calendar table
CREATE TABLE #calendar
(
DateValue DATE,
DayOfWeekNumber INT,
DayOfWeekName VARCHAR(32),
DayOfMonthNumber INT,
MonthNumber INT,
YearNumber INT,
WeekendFlag TINYINT,
HolidayFlag TINYINT
)
;

--Instead of inserting each row by typing it out individually, we can use recursive CTEs!
--Create recursive CTE and insert into DateValue
WITH DateSeries AS
(
SELECT CAST('2023-01-01' AS DATE) as MyDate     --Set your start date 

UNION ALL

SELECT
	DATEADD(DAY,1,MyDate)                       --Currently at 1 day. Change if you need to
FROM DateSeries
WHERE MyDate < CAST('2023-12-31' AS DATE)       --Set your end date
)

--Insert into the DateValue field in the Calendar table
INSERT INTO #calendar
(
DateValue
)

SELECT
MyDate
FROM DateSeries
OPTION(MAXRECURSION 15000)


--Update some of the other columns now that we have our DateValue column filled
UPDATE #calendar
SET
	DayOfWeekNumber = DATEPART(WEEKDAY,DateValue),
	DayOfWeekName = FORMAT(DateValue,'dddd'),
	DayOfMonthNumber = DAY(DateValue),
	MonthNumber = MONTH(DateValue),
	YearNumber = YEAR(DateValue)


--Update the weekend flag 
UPDATE #calendar
SET
	WeekendFlag = 	CASE 
					WHEN DayOfWeekName IN ('Saturday','Sunday') 
					THEN 1 
					ELSE 0 
					END


--Update the holiday flag. Add your own as well.
UPDATE #calendar
SET
	HolidayFlag = 	CASE 
					WHEN DayOfMonthNumber = 1 AND MonthNumber = 1
                        OR (DayOfMonthNumber = 31 AND MonthNumber = 10)
					    OR (DayOfMonthNumber = 24 AND MonthNumber = 12)
					    OR (DayOfMonthNumber = 25 AND MonthNumber = 12)
					    OR (DayOfMonthNumber = 31 AND MonthNumber = 12)
					THEN 1 
					ELSE 0 
					END

-------------------------------------------------------

-- Code for variables starts here --

--Variable for today
DECLARE @today DATE

SET @today = CAST(GETDATE() AS DATE)


-- Variable for Beginning of this month
DECLARE @BOM DATE

SET @BOM = DATEFROMPARTS(YEAR(@today),MONTH(@today),1)


-- Variable for Previous Beginning of Month
DECLARE @PrevBOM DATE

SET @PrevBOM = DATEADD(MONTH,-1,@BOM)

SELECT @PrevBOM

-- Variable for Previous End of Month
DECLARE @PrevEOM DATE

SET @PrevEOM = DATEADD(DAY,-1,@BOM)

SELECT @PrevEOM

-- Test out the variables.
-- Don't forget we need to highlight the previous variables along with our query
SELECT
*
FROM #calendar
WHERE DateValue <= @PrevBOM

-- Dropping the temp calendar table
DROP TABLE #calendar

;

/*

Variables - Exercise 2
Exercise
Let's say your company pays once per month, on the 15th.
If it's already the 15th of the current month (or later), the previous pay period will run from the 15th of the previous month, to the 14th of the current month.

If on the other hand it's not yet the 15th of the current month, the previous pay period will run from the
15th two months ago to the 14th on the previous month.

Set up variables defining the beginning and end of the previous pay period in this scenario. Select the variables to ensure they are working properly.
Hint: In addition to incorporating date logic, you will probably also need to use CASE statements in one of your variable definitions.

*/

-- Create variable for today
DECLARE @today DATE

SET @today = CAST(GETDATE() AS DATE)


-- Create variable for 15th of the current month
DECLARE @CM_15 DATE

SET @CM_15 = DATEFROMPARTS(YEAR(@today),MONTH(@today),15)


-- Create variable for 15th of previous month
DECLARE @PM_15 DATE

SET @PM_15 = DATEADD(MONTH,-1,@CM_15)


-- Create variable for 15th two months ago
DECLARE @P2M_15 DATE

SET @P2M_15 = DATEADD(MONTH,-2,@CM_15)


-- Create variable for the 14th of current month
DECLARE @CM_14 DATE

SET @CM_14 = DATEFROMPARTS(YEAR(@today),MONTH(@today),14)


-- Create variable for 14th of previous month
DECLARE @PM_14 DATE

SET @PM_14 = DATEADD(MONTH,-1,@CM_14)


-- Variable for Beginning of Pay Period
DECLARE @BPP DATE

SET @BPP =  CASE
            WHEN @today >= @CM_15
            THEN @PM_15
            ELSE @P2M_15
            END

-- Variable for End of Pay Period
DECLARE @EPP DATE

SET @EPP =  CASE
            WHEN @today >= @CM_15
            THEN @CM_14
            ELSE @PM_14
            END


-- Select the Beginning and End Pay Periods
SELECT @BPP
SELECT @EPP

-----------------------------------------------
-- The solution provided was a lot more elegant

DECLARE @Today DATE = CAST(GETDATE() AS DATE)

SELECT @Today

DECLARE @Current14 DATE = DATEFROMPARTS(YEAR(@Today),MONTH(@Today),14)

DECLARE @PayPeriodEnd DATE = 
	CASE
		WHEN DAY(@Today) < 15 THEN DATEADD(MONTH,-1,@Current14)
		ELSE @Current14
	END

DECLARE @PayPeriodStart DATE = DATEADD(DAY,1,DATEADD(MONTH,-1,@PayPeriodEnd))


SELECT @PayPeriodStart
SELECT @PayPeriodEnd

-----------------------------------------------------
-----------------------------------------------------
-------------  USER DEFINED FUNCTIONS  --------------
-----------------------------------------------------
/*

Doing a bit of hacking to make our own functions if the SQL function doesn't exist

*/

--When we create a function make sure we are working within the selected database or use the USE [database] GO syntax

USE AdventureWorks2017

GO

-- Create the function. name of the function is after dbo.
CREATE FUNCTION dbo.ufnCurrentDate() 				-- Empty parentheses is a must

RETURNS DATE 								--DATE is the datatype

AS											--keyword

BEGIN
	RETURN CAST(GETDATE() AS DATE)			--the function lives between BEGIN and END
END

;
-----------------------------------------------------
-- Example of using a User Defined Function below
SELECT
	SalesOrderID,
	OrderDate,
	DueDate,
	ShipDate,
	[Today] = dbo.ufnCurrentDate()

FROM AdventureWorks2017.Sales.SalesOrderHeader
;

-------------------------------------------------------
------------ Making Functions Flexible with Parameters
/*
Example of using user defined function

Business wants to know the count of Business days between the Order Date and Ship Date. 
*/

--Starter code
SELECT
	SalesOrderID,
	OrderDate,
	DueDate,
	ShipDate,
  	ElapsedBusinessDays = (
		SELECT
			COUNT(*)
		FROM AdventureWorks2019.dbo.Calendar B
		WHERE B.DateValue BETWEEN A.OrderDate AND A.ShipDate
			AND B.WeekendFlag = 0
			AND B.HolidayFlag = 0
	) - 1	
FROM AdventureWorks2017.Sales.SalesOrderHeader A

--Create the user defined function
USE AdventureWorks2017

GO

CREATE FUNCTION dbo.ufnElapsedBusinessDays(@StartDate DATE, @EndDate DATE) 	--Create the two parameters in the parentheses

RETURNS INT

AS

BEGIN

RETURN																		
		(
			SELECT
				COUNT(*)
			FROM AdventureWorks2017.dbo.Calendar

			WHERE DateValue BETWEEN @StartDate AND @EndDate
				AND WeekendFlag = 0
				AND HolidayFlag = 0
		)	- 1
END
;

-- Drop the Elapsed Business Days function
DROP FUNCTION dbo.ufnElapsedBusinessDays

-- Now use the function in the Starter code

SELECT
	SalesOrderID,
	OrderDate,
	DueDate,
	ShipDate,
  	ElapsedBusinessDays = dbo.ufnElapsedBusinessDays(OrderDate,ShipDate)	--We can even put in DueDate and other dates
 FROM AdventureWorks2017.Sales.SalesOrderHeader A

 ---------------------------------------------------
 /*
 User Defined Functions - Exercises

Exercise 1

Create a user-defined function that returns the percent that one number is of another.
For example, if the first argument is 8 and the second argument is 10, the function should return the string "80.00%".
The function should solve the "integer division" problem by allowing you to divide an integer by another integer, and yet get an accurate decimal result.

Hints:
Remember that you can implicitly convert an integer to a decimal by multiplying it by 1.0.
You can format a decimal (say, 0.1) as a percent (10%) with the following code: FORMAT(0.1, 'P').
Remember that the the return value of the function should be a text string.

*/

USE AdventureWorks2017

GO

CREATE FUNCTION dbo.ufnPercentage(@numerator INT, @denominator INT)

RETURNS VARCHAR(10)		--Don't forget about to change it to the desired output.

AS

BEGIN
	
DECLARE @Decimal FLOAT = ( @numerator * 1.0 / @denominator )

RETURN	FORMAT(@Decimal,'P')																		
		
END


-- If need to drop the created function
DROP FUNCTION dbo.ufnPercentage


--Testing to see if the function worked
SELECT
	SalesOrderID,
	OrderDate,
	DueDate,
	ShipDate,
  [percentage] = dbo.ufnPercentage(TaxAmt,TotalDue)
 FROM AdventureWorks2017.Sales.SalesOrderHeader A

--------------------------------------------------------------------------------
/*
Exercise 2
Store the maximum amount of vacation time for any individual employee in a variable.
Then create a query that displays all rows and the following columns from the AdventureWorks2019.HumanResources.Employee table:
BusinessEntityID
JobTitle
VacationHours

Then add a derived field called "PercentOfMaxVacation", which returns the percent an individual employees' vacation hours are of the maximum vacation hours for any employee.

For example, the record for the employee with the most vacation hours should have a value of 100.00%, in this column. The derived field should make use of your user-defined function from the previous exercise, as well as your variable that stored the maximum vacation hours for any employee.

*/

--Create max vacation time variable
DECLARE @MaxVacationHours FLOAT

SET @MaxVacationHours = (SELECT MAX(VacationHours) FROM AdventureWorks2017.HumanResources.Employee)

SELECT
	BusinessEntityID,
	JobTitle,
	VacationHours,
	PercentOfMaxVacation = dbo.ufnPercentage(VacationHours,@MaxVacationHours)
FROM AdventureWorks2017.HumanResources.Employee

--------------------------------------------------------------------------------

-----------------------------------------------------
----------------  STORED PROCEDURES  ----------------
-----------------------------------------------------

/*

Allows us to store sql queries in the database.
We can use this alongside parameters.

Syntax:

CREATE PROCEDURE dbo.[name of procedure]

AS

BEGIN
	
	[code]

END
*/

-- Below is an example of how we can convert a query into a stored procedures --

-- Starter Code
SELECT
	*
FROM(
	SELECT
		product_name = B.Name,
		line_total_sum = SUM(A.LineTotal),
		line_total_sum_rank = DENSE_RANK() OVER (ORDER BY Sum(A.LineTotal) DESC)

	FROM AdventureWorks2017.Sales.SalesOrderDetail A
		JOIN AdventureWorks2017.Production.Product B
			ON A.ProductID = B.ProductID
	
	GROUP BY
		B.Name
) X

WHERE line_total_sum_rank <= 10

-- Use the Syntax and insert the starter code into the code block
CREATE PROCEDURE dbo.OrdersReport

AS

BEGIN

	SELECT
		*
	FROM(
		SELECT
			product_name = B.Name,
			line_total_sum = SUM(A.LineTotal),
			line_total_sum_rank = DENSE_RANK() OVER (ORDER BY Sum(A.LineTotal) DESC)

		FROM AdventureWorks2017.Sales.SalesOrderDetail A
			JOIN AdventureWorks2017.Production.Product B
				ON A.ProductID = B.ProductID
	
		GROUP BY
			B.Name
			
		) X

	WHERE line_total_sum_rank <= 10

END
;


/* To check if the Stored Procedure actually worked, go into the Object Explorer (Connections view in VSCode) with all the folders, and refresh the "Stored Procedures" folder.

The folder can be found under "Programmability"

*/

-- To execute the stored procedure, use the syntax EXEC and the the procedure
EXEC dbo.OrdersReport


-- What if instead of top 10, we wanted the to make it more flexible so users could choose the top N instead? Let's Turn it into a parameter!

-- To do that, we replace the CREATE keyword with ALTER
/* How do we get to where the logic is stored on the server so we can change this?

In the Object Explorer:
- Programmability -> Stored Procedures
- Right click on the procedure
- If using SSMS:
	- Sript Stored Procedure as
	- ALTER To
	- New Query Editor Window
- In VSCode:
		- Select Script as Alter

- Modify the script to get the Top N parameter by adding a variable and data type in parentheses after the Stored Procedure name

*/

-- Below is the script that comes up
-- Change it by adding a variable and data type within parentheses after the procedures. Then replace the number for top N with the variable 
USE [AdventureWorks2017]
GO

/****** Object:  StoredProcedure [dbo].[OrdersReport]    Script Date: 9/10/2023 1:37:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[OrdersReport] (@TopN Int)

AS

BEGIN

	SELECT
		*
	FROM(
		SELECT
			product_name = B.Name,
			line_total_sum = SUM(A.LineTotal),
			line_total_sum_rank = DENSE_RANK() OVER (ORDER BY Sum(A.LineTotal) DESC)

		FROM AdventureWorks2017.Sales.SalesOrderDetail A
			JOIN AdventureWorks2017.Production.Product B
				ON A.ProductID = B.ProductID
	
		GROUP BY
			B.Name
			
		) X

	WHERE line_total_sum_rank <= @TopN

END
;
GO
;


-- Let's check if that worked by calling the Stored Procedure again and using the parameter
-- Execute the Store Procedure using Top 15
EXEC dbo.OrdersReport 15

-- Execute the Stored Procedure using Top 5
EXEC dbo.OrdersReport 5


--------------------------------------------------------------------------------------------------------------
/*

Stored Procedures - Exercise

Create a stored procedure called "OrdersAboveThreshold" that pulls in all sales orders with a total due amount above a threshold specified in a parameter called "@Threshold". The value for threshold will be supplied by the caller of the stored procedure.

The proc should have two other parameters: "@StartYear" and "@EndYear" (both INT data types), also specified by the called of the procedure. All order dates returned by the proc should fall between these two years.

*/


-- Begin by working out the SQL query to place in the code block
-- This is a placeholder select query
SELECT
		A.SalesOrderID,
		A.TotalDue,
		A.OrderDate

FROM 	sales.SalesOrderHeader A

WHERE 	A.TotalDue > 100
	AND	A.OrderDate BETWEEN '2013-01-01' AND '2013-12-31'
;


-- Insert the placeholder query into the syntax and replace with parameters
CREATE PROCEDURE dbo.OrdersAboveThreshold (@Threshold INT, @StartYear INT, @EndYear INT)

AS

BEGIN

SELECT
		A.SalesOrderID,
		A.TotalDue,
		A.OrderDate

FROM 	sales.SalesOrderHeader A

WHERE 	A.TotalDue >= @Threshold																	-- Replaced 100 with @Threshold INT variable
	AND	A.OrderDate BETWEEN DATEFROMPARTS(@StartYear,1,1) AND DATEFROMPARTS(@EndYear,12,31)		-- Replaced the date with @StartYear and @EndYear INT variables

END

-- Execute the procedure
EXEC dbo.OrdersAboveThreshold 10000, 2011, 2013

-------------------------------------------------------------------------------------------

-----------------------------------------------------
------------ CONTROL FLOW USING IF ------------------
-----------------------------------------------------

/* 
The difference between CASE statements and IF statements is:
- CASE statements only return values in a SELECT query.
- IF statements can execute whole query outputs and any other 'side effects'

Example below:
*/

-- Example of IF statement to return 'Hello, world!' using variable.
DECLARE @MyInput INT 

SET @MyInput = 2

IF @MyInput > 1
	BEGIN
	SELECT 'Hello, world!'
	END

-- Example of IF statement when the logical condition is NOT met.
DECLARE @MyInput INT 

SET @MyInput = 1	-- Changed @MyInput variable to 1 (which is not greater than 1)

IF @MyInput > 1
	BEGIN
	SELECT 'Hello, world!'
	END


-- Example of the IF ELSE
DECLARE @MyInput INT 

SET @MyInput = 1

IF @MyInput > 1
	BEGIN
	SELECT 'Hello, world!'
	END
ELSE
	BEGIN
	SELECT 'Farewell for now!'
	END


-- Proper example of using IF ELSE with Stored Procedure
-- We can ALTER the OrdersReport stored procedure amd add a parameter to switch between Sales or Purchase

-- The SCRIPT as ALTER
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[OrdersReport] (@TopN INT,@OrderType INT)			-- Added the new parameter in this line. User can type in 1 for sales orders. IF @OrderType = 1 THEN Sales ELSE Purchase.

AS

BEGIN																					-- This is BEGIN END block is for the stored procedure. Others are for the IF ELSE statement
	IF @OrderType = 1
		BEGIN
			SELECT
				*
			FROM(
				SELECT
					product_name = B.Name,
					line_total_sum = SUM(A.LineTotal),
					line_total_sum_rank = DENSE_RANK() OVER (ORDER BY Sum(A.LineTotal) DESC)

				FROM AdventureWorks2017.Sales.SalesOrderDetail A
					JOIN AdventureWorks2017.Production.Product B
						ON A.ProductID = B.ProductID
			
				GROUP BY
					B.Name
					
				) X

			WHERE line_total_sum_rank <= @TopN
		END
	
	ELSE
		BEGIN
			SELECT
				*
			FROM(
				SELECT
					product_name = B.Name,
					line_total_sum = SUM(A.LineTotal),
					line_total_sum_rank = DENSE_RANK() OVER (ORDER BY Sum(A.LineTotal) DESC)

				FROM AdventureWorks2017.Purchasing.PurchaseOrderDetail A
					JOIN AdventureWorks2017.Production.Product B
						ON A.ProductID = B.ProductID
			
				GROUP BY
					B.Name
					
				) X

			WHERE line_total_sum_rank <= @TopN
		END

END
;
GO


-- Execute the procedure, using 1 in the second parameter for top N sales orders
EXEC dbo.OrdersReport 15,1

-- Execute the procedure, using any other number in the second parameter for top N purchase orders
EXEC dbo.OrdersReport 15,2

----------------------------------------------------------------------------------------------------

/*
Control Flow With IF Statements - Exercise
Modify the stored procedure you created for the stored procedures exercise (dbo.OrdersAboveThreshold) to include an additional parameter called "@OrderType" (data type INT).
If the user supplies a value of 1 to this parameter, your modified proc should return the same output as previously.
If however the user supplies a value of 2, your proc should return purchase orders instead of sales orders.
Use IF/ELSE blocks to accomplish this.
*/

-- Original stored procedure code
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[OrdersAboveThreshold] (@Threshold INT, @StartYear INT, @EndYear INT)

AS

BEGIN

SELECT
		A.SalesOrderID,
		A.TotalDue,
		A.OrderDate

FROM 	sales.SalesOrderHeader A

WHERE 	A.TotalDue >= @Threshold																	-- Replaced 100 with @Threshold INT variable
	AND	A.OrderDate BETWEEN DATEFROMPARTS(@StartYear,1,1) AND DATEFROMPARTS(@EndYear,12,31)		-- Replaced the date with @StartYear and @EndYear INT variables

END
GO


-- Modified stored procedure code
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[OrdersAboveThreshold] (@Threshold INT, @OrderType INT, @StartYear INT, @EndYear INT)

AS

BEGIN
	IF @OrderType = 1
		BEGIN
			SELECT
					A.SalesOrderID,
					A.TotalDue,
					A.OrderDate

			FROM 	sales.SalesOrderHeader A

			WHERE 	A.TotalDue >= @Threshold
				AND	A.OrderDate BETWEEN DATEFROMPARTS(@StartYear,1,1) AND DATEFROMPARTS(@EndYear,12,31)																
																	

		END
	ELSE
		BEGIN
			SELECT
					A.PurchaseOrderID,
					A.TotalDue,
					A.OrderDate

			FROM 	Purchasing.PurchaseOrderHeader A

			WHERE 	A.TotalDue >= @Threshold
				AND	A.OrderDate BETWEEN DATEFROMPARTS(@StartYear,1,1) AND DATEFROMPARTS(@EndYear,12,31)																

		END	
END
GO

-- Execute the program to test. @OrderType = 1
EXEC dbo.OrdersAboveThreshold 10000,1,2011,2013

-- Execute the program to test. @OrderType = 2
EXEC dbo.OrdersAboveThreshold 10000,2,2011,2013

-------------------------------------------------------------------------------------------

-----------------------------------------------------
------------ MULTIPLE IF STATEMENTS------------------
-----------------------------------------------------

/* 
SQL does NOT have an IFELSE statement

One workaround is to nest it, but that's ugly (like in Power BI DAX)

Another way we can do this is if we just convert the ELSE block into an IF block

The way it works is that if the first condition is not met, move onto the next, then the next and so on.

As long as the IF statements do not overlap.
*/

--Multiple IF statement example
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE dbo.OrdersReport(@TopN INT, @OrderType INT)

AS

BEGIN

	IF @OrderType = 1
		BEGIN
			SELECT
				*
			FROM (
				SELECT 
					ProductName = B.[Name],
					LineTotalSum = SUM(A.LineTotal),
					LineTotalSumRank = DENSE_RANK() OVER(ORDER BY SUM(A.LineTotal) DESC)

				FROM AdventureWorks2017.Sales.SalesOrderDetail A
					JOIN AdventureWorks2017.Production.Product B
						ON A.ProductID = B.ProductID

				GROUP BY
					B.[Name]
				) X

			WHERE LineTotalSumRank <= @TopN
		END
	IF @OrderType = 2
		BEGIN
				SELECT
					*
				FROM(
					SELECT 
						ProductName = B.[Name],
						LineTotalSum = SUM(A.LineTotal),
						LineTotalSumRank = DENSE_RANK() OVER(ORDER BY SUM(A.LineTotal) DESC)

					FROM AdventureWorks2017.Purchasing.PurchaseOrderDetail A
						JOIN AdventureWorks2017.Production.Product B
							ON A.ProductID = B.ProductID

					GROUP BY
						B.[Name]
					) X

				WHERE LineTotalSumRank <= @TopN
			END

	IF @OrderType = 3											-- @OrderType = 3 is a temp table that unions sales and purchases
		BEGIN
			-- Create temp table and insert sales				
			SELECT
				ProductID,
				LineTotal

			INTO #AllOrders

			FROM AdventureWorks2017.Sales.SalesOrderDetail

			-- Inserting Purchase Orders
			INSERT INTO #AllOrders

			SELECT
				ProductID,
				LineTotal

			FROM AdventureWorks2017.Purchasing.PurchaseOrderDetail
					
			-- Calling the temp table 
			SELECT
				*
			FROM (
				SELECT 
					ProductName = B.[Name],
					LineTotalSum = SUM(A.LineTotal),
					LineTotalSumRank = DENSE_RANK() OVER(ORDER BY SUM(A.LineTotal) DESC)

				FROM #AllOrders A
					JOIN AdventureWorks2017.Production.Product B
						ON A.ProductID = B.ProductID

				GROUP BY
					B.[Name]
				) X

			WHERE LineTotalSumRank <= @TopN

			DROP TABLE #AllOrders
		END
END



--Call modified stored procedure


EXEC dbo.OrdersReport 20,1

EXEC dbo.OrdersReport 15,2

EXEC dbo.OrdersReport 25,3

-----------------------------------------------------------------------------------

/*
Using Multiple IF Statements - Exercise

Modify your "dbo.OrdersAboveThreshold" stored procedure once again, such that if a user supplies a value of 3 to the @OrderType parameter, the proc should return all sales AND purchase orders above the specified threshold, with order dates between the specified years.

In this scenario, include an "OrderType" column to the procedure output. This column should have a value of "Sales" for records from the SalesOrderHeader table, and "Purchase" for records from the PurchaseOrderHeader table.

Hints:
- Convert your ELSE block to an IF block, so that you now have 3 independent IF blocks.
- Make sure that your IF criteria are all mutually exclusive.
- Use UNION ALL to "stack" the sales and purchase data.
- Alias SalesOrderId/PurchaseOrderID as "OrderID" in their respective UNION-ed queries.
*/


-- Modifying the script
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[OrdersAboveThreshold] (@Threshold INT, @OrderType INT, @StartYear INT, @EndYear INT)

AS

BEGIN
	-- First OrderType for sales
	IF @OrderType = 1
		BEGIN
			SELECT
					A.SalesOrderID,
					A.TotalDue,
					A.OrderDate

			FROM 	sales.SalesOrderHeader A

			WHERE 	A.TotalDue >= @Threshold
				AND	A.OrderDate BETWEEN DATEFROMPARTS(@StartYear,1,1) AND DATEFROMPARTS(@EndYear,12,31)																

			ORDER BY OrderDate ASC								

		END
	
	-- Second OrderType for purchases
	IF @OrderType = 2
		BEGIN
			SELECT
					A.PurchaseOrderID,
					A.TotalDue,
					A.OrderDate

			FROM 	Purchasing.PurchaseOrderHeader A

			WHERE 	A.TotalDue >= @Threshold

			ORDER BY OrderDate ASC	

		END	
	
	-- Third OrderType for both
	IF @OrderType = 3
		BEGIN
			SELECT
					A.SalesOrderID as [OrderID],
					A.TotalDue,
					A.OrderDate

			FROM 	sales.SalesOrderHeader A

			WHERE 	A.TotalDue >= @Threshold
				AND	A.OrderDate BETWEEN DATEFROMPARTS(@StartYear,1,1) AND DATEFROMPARTS(@EndYear,12,31)		

				UNION ALL
			
			SELECT
					A.PurchaseOrderID as [OrderID],
					A.TotalDue,
					A.OrderDate

			FROM 	Purchasing.PurchaseOrderHeader A

			WHERE 	A.TotalDue >= @Threshold
				AND	A.OrderDate BETWEEN DATEFROMPARTS(@StartYear,1,1) AND DATEFROMPARTS(@EndYear,12,31)	

			ORDER BY OrderDate ASC	

		END
END
GO


-- Call the modified stored procedure
EXEC dbo.OrdersAboveThreshold 10000,1,2011,2013

EXEC dbo.OrdersAboveThreshold 10000,2,2011,2013

EXEC dbo.OrdersAboveThreshold 10000,3,2011,2013

-----------------------------------------------------------------------------------

-----------------------------------------------------
--------------- DYNAMIC SQL PT 1 --------------------
-----------------------------------------------------

/*

Writing code that writes code? Seems like AI. This section is not quite that, but it's more like turning queries into strings, and then passing through variables where the user can make their input via parameters. 

We can concatenate these query strings to create Dynamic SQL queries 

*/

/* Simple example below */
-- The below is the query we want to use
SELECT TOP 100 * FROM AdventureWorks2017.Production.Product


-- Let's create some dynamic SQL. Start with making a variable
DECLARE @DynamicSQL VARCHAR(MAX)

SET @DynamicSQL = 'SELECT TOP 100 * FROM AdventureWorks2017.Production.Product'

-- To execute the variable, if it is a string, we will need to wrap the variable in parentheses
EXEC(@DynamicSQL)


/* Use case example - part 1 */

-- Below is a part 1 of an example.
-- The starting code
SELECT
	*
FROM(
	SELECT
		ProductName = B.Name,
		LineTotalSum = SUM(A.LineTotal),
		LineTotalSumRank = DENSE_RANK() OVER (ORDER BY SUM(A.LineTotal) DESC)
	FROM AdventureWorks2017.Sales.SalesOrderDetail A
		JOIN AdventureWorks2017.Production.Product B
			ON A.ProductID = B.ProductID

	GROUP BY
		B.Name
	) X

WHERE LineTotalSumRank <= 10


-- Declaring the variables
DECLARE @TopN INT = 10
DECLARE @AggFunction VARCHAR(50) = 'AVG'
DECLARE @DynamicSQL VARCHAR(MAX)


-- Set our variable with the SQL Query up to where the next variable and wrap it in quotation conert the query into a string
SET @DynamicSQL	= 'SELECT
		*
	FROM(
		SELECT
			ProductName = B.Name,
			LineTotalSum = '


-- Like in Python, update the variable by having it = itself + the next string
SET @DynamicSQL = @DynamicSQL + @AggFunction


-- Again, copy the SQL query from after the SUM to the next SUM and then append the variable, up to where we want @TopN
SET @DynamicSQL	= @DynamicSQL + '(A.LineTotal),
		LineTotalSumRank = DENSE_RANK() OVER (ORDER BY '

SET @DynamicSQL = @DynamicSQL + @AggFunction

SET @DynamicSQL = @DynamicSQL + '(A.LineTotal) DESC)
	FROM AdventureWorks2017.Sales.SalesOrderDetail A
		JOIN AdventureWorks2017.Production.Product B
			ON A.ProductID = B.ProductID

	GROUP BY
		B.Name
	) X 

WHERE LineTotalSumRank <= '

-- Append the @TopN variable. Don't forget it has to be a string so CAST the INT variable
SET @DynamicSQL = @DynamicSQL + CAST(@TopN as VARCHAR)


-- Test the variable out with a SELECT statement (don't forget to highlight everything from DECLARE)
SELECT @DynamicSQL

----------------------------------------------------------------------------
-- How to turn it into a stored procedure
CREATE PROCEDURE dbo.DynamicTopN(@TopN INT, @AggFunction VARCHAR(50))

AS

BEGIN
	-- We can remove the variables that are being used by parameters. ie. TopN and AggFunction
	DECLARE @DynamicSQL VARCHAR(MAX)

	SET @DynamicSQL	= 'SELECT
			*
		FROM(
			SELECT
				ProductName = B.Name,
				LineTotalSum = '


	SET @DynamicSQL = @DynamicSQL + @AggFunction


	SET @DynamicSQL	= @DynamicSQL + '(A.LineTotal),
			LineTotalSumRank = DENSE_RANK() OVER (ORDER BY '

	SET @DynamicSQL = @DynamicSQL + @AggFunction

	SET @DynamicSQL = @DynamicSQL + '(A.LineTotal) DESC)
		FROM AdventureWorks2017.Sales.SalesOrderDetail A
			JOIN AdventureWorks2017.Production.Product B
				ON A.ProductID = B.ProductID

		GROUP BY
			B.Name
		) X 

	WHERE LineTotalSumRank <= '

	SET @DynamicSQL = @DynamicSQL + CAST(@TopN as VARCHAR)

	EXEC(@DynamicSQL)

END
;

-- Test the stored procedure
EXEC dbo.DynamicTopN 15,'AVG'

EXEC dbo.DynamicTopN 5,'MAX'

EXEC dbo.DynamicTopN 10,'SUM'
;

-------------------------------------------------------------------------------------------------------------------------
/* Dynamic SQL - Exercises
Exercise 1

Create a stored procedure called "NameSearch" that allows users to search the Person.Person table for a pattern provided by the user.

The user should be able to search by either first name, last name, or middle name.

You can return all columns from the table; that is to say, feel free to use SELECT *.

The stored procedure should take two arguments:
- @NameToSearch: The user will be expected to enter either "first", "middle", or "last". This way, they do not have to remember exact column names.
- @SearchPattern: The user will provide a text string to search for.

A record should be returned if the specified name (first, middle, or last) includes the specified pattern anywhere within it.

I.e., if the user tells us to search the FirstName field for the pattern "ravi", both the names "Ravi" and "Travis" should be returned.

Hints:
- You will probably want to use LIKE with a wildcard in your WHERE clause.
- To include single quotes in your dynamic SQL, try "escaping" them by typing four consecutive single quotes ('''').
- Try creating a variable to hold the actual column name to search, and then set this variable using IF statements, based on the value passed into the "NameToSearch" parameter by the user. Then simply plug this variable into your dynamic SQL. This is easier than having to execute different queries depending on what was passed in.

*/

-- Start with a simple SELECT query
SELECT
	*
FROM Person.Person
WHERE FirstName LIKE '%an%'
;

-- Declare variables and replace it in the Select Statement
DECLARE @NameToSearch VARCHAR(30) = 'FirstName'
DECLARE @SearchPattern VARCHAR(255) = 'an'
DECLARE @NameSearchVar VARCHAR(MAX) = 'SELECT
	* 
FROM Person.Person 
WHERE '

-- Set the @NameSearchVar and @NameToSearch variables in place
SET @NameSearchVar = @NameSearchVar + @NameToSearch + ' LIKE '

-- Set the @SearchPatter and update @NameSearchVar 
SET @NameSearchVar = @NameSearchVar + '''%' + @SearchPattern + '%'''

-- Test the @NameSearchVar 
-- SELECT @NameSearchVar

-- Run the @NameSearchVar
EXEC @NameSearchVar
;

-- Turning  it into a stored procedure
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[NameSearch] (@NameToSearch VARCHAR(30), @SearchPattern VARCHAR(255))

AS

BEGIN
	-- Make the first variable
	DECLARE @NameSearchVar VARCHAR(MAX) = 'SELECT
		* 
	FROM Person.Person 
	WHERE '


	-- first name condition
	IF @NameToSearch = 'first'
	BEGIN
		SET @NameSearchVar = @NameSearchVar + 'FirstName' + ' LIKE '

		SET @NameSearchVar = @NameSearchVar + '''%' + @SearchPattern + '%'''

		EXEC (@NameSearchVar)
	END


	-- middle name condition
	IF @NameToSearch = 'middle'
	BEGIN
		SET @NameSearchVar = @NameSearchVar + 'MiddleName' + ' LIKE '

		SET @NameSearchVar = @NameSearchVar + '''%' + @SearchPattern + '%'''

		EXEC (@NameSearchVar)
	END


	-- last name condition
	IF @NameToSearch = 'last'
	BEGIN
		SET @NameSearchVar = @NameSearchVar + 'LastName' + ' LIKE '

		SET @NameSearchVar = @NameSearchVar + '''%' + @SearchPattern + '%'''

		EXEC (@NameSearchVar)
	END
END

-- Test stored procedure (procedures don't need parentheses for parameters)
EXEC dbo.NameSearch first,Andrew


/*
Exercise 2

Modify your "NameSearch" procedure to accept a third argument - @MatchType, with an INT datatype -  that specifies the match type:

1 means "exact match"

2 means "begins with"

3 means "ends with"

4 means "contains"

Hint: Use a series of IF statements to build out your WHERE clause based on the @MatchType parameter, then append this to the rest of your dynamic SQL before executing. */

-- Start with a normal select query to understand
SELECT
	*
FROM Person.Person
WHERE FirstName LIKE '%an%' -- We will be editing LIKE and the wildcard (in quotation)

-- Refactoring the stored procedure
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[NameSearch] (@NameToSearch VARCHAR(30), @MatchType INT, @SearchPattern VARCHAR(255))

AS

BEGIN
-- First DECLARE VARIABLES
	DECLARE @NameSearchVar VARCHAR(MAX) 
	DECLARE @MatchTypeConditions VARCHAR(MAX)
	DECLARE @NameColumn VARCHAR (100)		-- New variable to change column 

-- Secondly, outline the IF Conditions - @MatchType
	-- Condition 1: @Matchtype is 'exact match'
	IF @MatchType = 1
		SET @MatchTypeConditions = ' = ''' + @SearchPattern + ''''

	-- Condition 2: @Matchtype is 'begins with'
	IF @MatchType = 2
		SET @MatchTypeConditions = ' LIKE ' + '''' + @SearchPattern + '%'''

	-- Condition 3: @Matchtype is 'ends with'
	IF @MatchType = 3
		SET @MatchTypeConditions = ' LIKE ''%' + @SearchPattern + ''''

	-- Condition 4: @Matchtype is 'contains'
	IF @MatchType = 4
		SET @MatchTypeConditions = ' LIKE ''%' + @SearchPattern + '%'''

-- Thirdly, outline IF conditions for the name column
	-- first name condition: set NameColumn variable to FirstName
	IF @NameToSearch = 'first'
		SET @NameColumn = 'FirstName'

	-- middle name condition: set NameColumn variable to MiddleName
	IF @NameToSearch = 'middle'
		SET @NameColumn = 'MiddleName'

	-- middle name condition: set NameColumn variable to MiddleName
	IF @NameToSearch = 'last'
		SET @NameColumn = 'LastName'

-- Set the @NameSerachVar variables (last one to set)
	SET @NameSearchVar = 'SELECT * FROM Person.Person WHERE ' 

-- Concat with other variables using the python append method
	SET @NameSearchVar = @NameSearchVar + @NameColumn + @MatchTypeConditions

-- Lastly, execute the string as a SQL query
	EXEC (@NameSearchVar)

END

-- Test stored procedure (procedures don't need parentheses for parameters)
EXEC dbo.NameSearch first,3,y
