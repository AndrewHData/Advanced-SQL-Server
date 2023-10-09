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

WHERE 	A.TotalDue > @Threshold																	-- Replaced 100 with @Threshold INT variable
	AND	A.OrderDate BETWEEN DATEFROMPARTS(@StartYear,1,1) AND DATEFROMPARTS(@EndYear,12,31)		-- Replaced the date with @StartYear and @EndYear INT variables

END