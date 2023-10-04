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

-----------------------------------------------