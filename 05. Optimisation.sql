--------------------------------------------------
-----------------  OPTIMISATION ------------------
--------------------------------------------------

/*

--------------------------------------------------
-----------  OPTIMISATION WITH UPDATE ------------
--------------------------------------------------
JOINing table is heavy on the server.

Better to avoid several joins of full tables

Might be better to make temp tables that are smaller and using the temp tables to join to speed up the query.

Process is:
- Make a foundational temp table that only contains data you need.
- Populate it with relevant data (WHERE CLAUSE)
*/

--Starter Code:

SELECT 
	   A.SalesOrderID
	  ,A.OrderDate
      ,B.ProductID
      ,B.LineTotal
	  ,C.[Name] AS ProductName
	  ,D.[Name] AS ProductSubcategory
	  ,E.[Name] AS ProductCategory


FROM AdventureWorks2017.Sales.SalesOrderHeader A
	JOIN AdventureWorks2017.Sales.SalesOrderDetail B
		ON A.SalesOrderID = B.SalesOrderID
	JOIN AdventureWorks2017.Production.Product C
		ON B.ProductID = C.ProductID
	JOIN AdventureWorks2017.Production.ProductSubcategory D
		ON C.ProductSubcategoryID = D.ProductSubcategoryID
	JOIN AdventureWorks2017.Production.ProductCategory E
		ON D.ProductCategoryID = E.ProductCategoryID

WHERE YEAR(A.OrderDate) = 2012
;

--Optimized script


--1.) Create filtered temp table of sales order header table WHERE year = 2012

CREATE TABLE #Sales2012 
(
SalesOrderID INT,
OrderDate DATE
)

INSERT INTO #Sales2012
(
SalesOrderID,
OrderDate
)

SELECT
SalesOrderID,
OrderDate

FROM AdventureWorks2017.Sales.SalesOrderHeader

WHERE YEAR(OrderDate) = 2012




--2.) Create new temp table after joining in SalesOrderDetail  table

CREATE TABLE #ProductsSold2012
(
SalesOrderID INT,
OrderDate DATE,
LineTotal MONEY,
ProductID INT,
ProductName VARCHAR(64),
ProductSubcategoryID INT,
ProductSubcategory VARCHAR(64),
ProductCategoryID INT,
ProductCategory VARCHAR(64)
)

INSERT INTO #ProductsSold2012
(
SalesOrderID,
OrderDate,
LineTotal,
ProductID
)

SELECT 
	   A.SalesOrderID
	  ,A.OrderDate
      ,B.LineTotal
      ,B.ProductID

FROM #Sales2012 A
	JOIN AdventureWorks2017.Sales.SalesOrderDetail B
		ON A.SalesOrderID = B.SalesOrderID



--3.) Add product data with UPDATE

UPDATE A
SET
ProductName = B.[Name],
ProductSubcategoryID = B.ProductSubcategoryID

FROM #ProductsSold2012 A
	JOIN AdventureWorks2017.Production.Product B
		ON A.ProductID = B.ProductID



--4.) Add product subcategory with UPDATE

UPDATE A
SET
ProductSubcategory= B.[Name],
ProductCategoryID = B.ProductCategoryID

FROM #ProductsSold2012 A
	JOIN AdventureWorks2017.Production.ProductSubcategory B
		ON A.ProductSubcategoryID = B.ProductSubcategoryID





--5.) Add product category data with UPDATE


UPDATE A
SET
ProductCategory= B.[Name]

FROM #ProductsSold2012 A
	JOIN AdventureWorks2017.Production.ProductCategory B
		ON A.ProductCategoryID = B.ProductCategoryID


SELECT * FROM #ProductsSold2012
;


DROP TABLE
	#ProductsSold2012,
	#Sales2012

-------------------------------------------------------------------------------------------------------------------------------------
/*
Optimizing With UPDATE - Exercise
Exercise
Making use of temp tables and UPDATE statements, re-write an optimized version of the query in the "Optimizing With UPDATE - Exercise Starter Code.sql" file, which you'll find in the resources for this section.
*/
------------------------------------------------------------------------------------------
-- Starter code
SELECT 
	   A.BusinessEntityID
      ,A.Title
      ,A.FirstName
      ,A.MiddleName
      ,A.LastName
	  ,B.PhoneNumber
	  ,PhoneNumberType = C.Name
	  ,D.EmailAddress

FROM AdventureWorks2017.Person.Person A
	LEFT JOIN AdventureWorks2017.Person.PersonPhone B
		ON A.BusinessEntityID = B.BusinessEntityID
	LEFT JOIN AdventureWorks2017.Person.PhoneNumberType C
		ON B.PhoneNumberTypeID = C.PhoneNumberTypeID
	LEFT JOIN AdventureWorks2017.Person.EmailAddress D
		ON A.BusinessEntityID = D.BusinessEntityID
;

------------------------------------------------------------------------------------------
-- Optimised code

-- Create new temp table to store persons
CREATE TABLE #person_details
(
BusinessEntityID INT,
Title VARCHAR(10),
FirstName VARCHAR(64),
MiddleName VARCHAR(64),
LastName VARCHAR(64),
PhoneNumber VARCHAR(64),
PhoneNumberType VARCHAR(10),
PhoneNumberTypeID INT,
EmailAddress VARCHAR(64)
)

-- Insert into temp table 
INSERT INTO #person_details
(
BusinessEntityID,
Title,
FirstName,
MiddleName,
LastName
)

SELECT 
	Person.BusinessEntityID,
	Person.Title,
	Person.FirstName,
	Person.MiddleName,
	Person.LastName
FROM Person.Person

;
DROP TABLE #person_details
;
SELECT * FROM #person_details
;
-- Add PhoneNumber using UPDATE and ADD PhoneNumberTypeID
UPDATE #person_details
SET
	PhoneNumber = B.PhoneNumber,
	PhoneNumberTypeID = B.PhoneNumberTypeID
FROM #person_details A
	JOIN Person.PersonPhone B
		ON A.BusinessEntityID = B.BusinessEntityID

-- Add PhoneNumberType from Person.PhoneNumberType table using UPDATE
UPDATE #person_details
SET
	PhoneNumberType = B.Name
FROM #person_details A
	LEFT JOIN Person.PhoneNumberType B
		ON A.PhoneNumberTypeID = B.PhoneNumberTypeID

-- Add EmailAddress from Person.EmailAddress table using UPDATE
UPDATE A
SET
	EmailAddress = D.EmailAddress
FROM #person_details A
	LEFT JOIN AdventureWorks2017.Person.EmailAddress D
		ON A.BusinessEntityID = D.BusinessEntityID

-- Select all to check table
SELECT * FROM #person_details

-- Drop table to finish
DROP TABLE #person_details

;

-------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------
---------------  EXIST WITH UPDATE ---------------
--------------------------------------------------

/*
Useful for when you only want ONE SINGLE MATCH instead of multiple.

We can use UPDATE to recreate the functionality of EXISTS 

Eg. There are many Sales Order Detail in a Sales Order Header. You only want one.

--------------------
When should you use what technique?
- If you need to see all matches from the many side of the relationship, use a JOIN.
- If you don't want to see all matches from the many side, AND don't care to see any information about those matches (other than their existence), EXISTS is fine.
- If you don't want to see all matches from the many side, but would like some information about a (any) match that was returned, use UPDATE.
----------------

Example below
*/


--Select all orders with at least one item over 10K, using EXISTS

SELECT
       A.SalesOrderID
      ,A.OrderDate
      ,A.TotalDue

FROM AdventureWorks2017.Sales.SalesOrderHeader A

WHERE EXISTS (
	SELECT
	1
	FROM AdventureWorks2017.Sales.SalesOrderDetail B
	WHERE A.SalesOrderID = B.SalesOrderID
		AND B.LineTotal > 10000
)

ORDER BY 1



--5.) Select all orders with at least one item over 10K, including a line item value, using UPDATE

--Create a table with Sales data, including a field for line total:
CREATE TABLE #Sales
(
SalesOrderID INT,
OrderDate DATE,
TotalDue MONEY,
LineTotal MONEY
)


--Insert sales data to temp table
INSERT INTO #Sales
(
SalesOrderID,
OrderDate,
TotalDue
)

SELECT
SalesOrderID,
OrderDate,
TotalDue

FROM AdventureWorks2017.Sales.SalesOrderHeader


--Update temp table with > 10K line totals

UPDATE A
SET LineTotal = B.LineTotal

FROM #Sales A
	JOIN AdventureWorks2017.Sales.SalesOrderDetail B
		ON A.SalesOrderID = B.SalesOrderID
WHERE B.LineTotal > 10000


--Recreate EXISTS:

SELECT * FROM #Sales WHERE LineTotal IS NOT NULL


--Recreate NOT EXISTS:

SELECT * FROM #Sales WHERE LineTotal IS NULL

--Drop the temp table to finish
DROP TABLE #Sales

--------------------------------------------------------------
/*

An Improved EXISTS With UPDATE - Exercise

Exercise
Re-write the query in the "An Improved EXISTS With UPDATE - Exercise Starter Code.sql" file (you can find the file in the Resources for this section), using temp tables and UPDATEs instead of EXISTS.
In addition to the three columns in the original query, you should also include a fourth column called "RejectedQty", which has one value for rejected quantity from the Purchasing.PurchaseOrderDetail table.

*/

-- Starter Code
SELECT
       A.PurchaseOrderID,
	   A.OrderDate,
	   A.TotalDue

FROM AdventureWorks2017.Purchasing.PurchaseOrderHeader A

WHERE EXISTS (
	SELECT
	1
	FROM AdventureWorks2017.Purchasing.PurchaseOrderDetail B
	WHERE A.PurchaseOrderID = B.PurchaseOrderID
		AND B.RejectedQty > 5
)

ORDER BY 1

-- Re-written Code

--Insert Purchase data into temp table
CREATE TABLE #purchases
(
PurchaseOrderID INT,
OrderDate DATE,
TotalDue MONEY,
RejectedQty INT
)

INSERT INTO #purchases
(
PurchaseOrderID,
OrderDate,
TotalDue
)

SELECT
	A.PurchaseOrderID,
	A.OrderDate,
	A.TotalDue
FROM Purchasing.PurchaseOrderHeader A

--Update temp table with B.RejectedQty > 5
UPDATE A
SET
	RejectedQty = B.RejectedQty

FROM #purchases A
	JOIN Purchasing.PurchaseOrderDetail B
		ON A.PurchaseOrderID = B.PurchaseOrderID
WHERE B.RejectedQty > 5


--Recreate EXISTS
SELECT * 
FROM #purchases
WHERE RejectedQty IS NOT NULL

--Recreate NOT EXISTS
SELECT * 
FROM #purchases
WHERE RejectedQty IS NULL

--SELECT ALL
SELECT * 
FROM #purchases

--DROP TABLE #purchases
DROP TABLE #purchases

-------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------
----------- OPTIMISING WITH INDEXES --------------
--------------------------------------------------

/*

Indexes are database objects that can make queries against your  table faster
This sorting allows database engine to locate records in a table without needing to go row-by-row

Two types of Indexes:
- Clustered Index: Basically the Primary Key
- Non-clustered Index: Probably the Foreign Key

Downsides of Index: 
- They take up memory
- Makes inserts into tables longer

When to use it?
Use clustered index if our temp table will be joiing with others. 

Example below
*/

--Create temp table
CREATE TABLE #Sales2012 
(
SalesOrderID INT,
OrderDate DATE
)

INSERT INTO #Sales2012
(
SalesOrderID,
OrderDate
)

SELECT
SalesOrderID,
OrderDate

FROM AdventureWorks2017.Sales.SalesOrderHeader

WHERE YEAR(OrderDate) = 2012


--1.) Add clustered index to #Sales2012


CREATE CLUSTERED INDEX Sales2012_idx ON #Sales2012(SalesOrderID)


--2.) Add sales order detail ID

CREATE TABLE #ProductsSold2012
(
SalesOrderID INT,
SalesOrderDetailID INT, --Add for clustered index
OrderDate DATE,
LineTotal MONEY,
ProductID INT,
ProductName VARCHAR(64),
ProductSubcategoryID INT,
ProductSubcategory VARCHAR(64),
ProductCategoryID INT,
ProductCategory VARCHAR(64)
)

INSERT INTO #ProductsSold2012
(
SalesOrderID,
SalesOrderDetailID,
OrderDate,
LineTotal,
ProductID
)

SELECT 
	   A.SalesOrderID
	  ,B.SalesOrderDetailID
	  ,A.OrderDate
      ,B.LineTotal
      ,B.ProductID

FROM #Sales2012 A
	JOIN AdventureWorks2017.Sales.SalesOrderDetail B
		ON A.SalesOrderID = B.SalesOrderID


--3.) Add clustered index on SalesOrderDetailID

CREATE CLUSTERED INDEX ProductsSold2012_idx ON #ProductsSold2012(SalesOrderDetailID)


--4.) Add nonclustered index on product Id

CREATE NONCLUSTERED INDEX ProductsSold2012_idx2 ON #ProductsSold2012(ProductID)



--3.) Add product data with UPDATE


UPDATE A
SET
ProductName = B.[Name],
ProductSubcategoryID = B.ProductSubcategoryID

FROM #ProductsSold2012 A
	JOIN AdventureWorks2019.Production.Product B
		ON A.ProductID = B.ProductID


--4.) Add nonclustered index on product subcategory ID

CREATE NONCLUSTERED INDEX ProductsSold2012_idx3 ON #ProductsSold2012(ProductSubcategoryID)






UPDATE A
SET
ProductSubcategory= B.[Name],
ProductCategoryID = B.ProductCategoryID

FROM #ProductsSold2012 A
	JOIN AdventureWorks2019.Production.ProductSubcategory B
		ON A.ProductSubcategoryID = B.ProductSubcategoryID


--5) Add nonclustered index on category Id

CREATE NONCLUSTERED INDEX ProductsSold2012_idx4 ON #ProductsSold2012(ProductCategoryID)



UPDATE A
SET
ProductCategory= B.[Name]

FROM #ProductsSold2012 A
	JOIN AdventureWorks2019.Production.ProductCategory B
		ON A.ProductCategoryID = B.ProductCategoryID


SELECT * FROM #ProductsSold2012

-------------------------------------------------------------------------------------------------------------------------------------

/*
Optimizing With Indexes - Exercise
Exercise
Using indexes, further optimize your solution to the "Optimizing With UPDATE" exercise. You can find the starter code in the "Optimizing With UPDATE - Exercise Starter Code.sql" file in the Resources for this section.
*/

-- Starter Code
CREATE TABLE #PersonContactInfo
(
	   BusinessEntityID INT
      ,Title VARCHAR(8)
      ,FirstName VARCHAR(50)
      ,MiddleName VARCHAR(50)
      ,LastName VARCHAR(50)
	  ,PhoneNumber VARCHAR(25)
	  ,PhoneNumberTypeID VARCHAR(25)
	  ,PhoneNumberType VARCHAR(25)
	  ,EmailAddress VARCHAR(50)
)

INSERT INTO #PersonContactInfo
(
	   BusinessEntityID
      ,Title
      ,FirstName
      ,MiddleName
      ,LastName
)

SELECT
	   BusinessEntityID
      ,Title
      ,FirstName
      ,MiddleName
      ,LastName

FROM AdventureWorks2017.Person.Person


UPDATE A
SET
	PhoneNumber = B.PhoneNumber,
	PhoneNumberTypeID = B.PhoneNumberTypeID

FROM #PersonContactInfo A
	JOIN AdventureWorks2017.Person.PersonPhone B
		ON A.BusinessEntityID = B.BusinessEntityID


UPDATE A
SET	PhoneNumberType = B.Name

FROM #PersonContactInfo A
	JOIN AdventureWorks2017.Person.PhoneNumberType B
		ON A.PhoneNumberTypeID = B.PhoneNumberTypeID


UPDATE A
SET	EmailAddress = B.EmailAddress

FROM #PersonContactInfo A
	JOIN AdventureWorks2017.Person.EmailAddress B
		ON A.BusinessEntityID = B.BusinessEntityID


SELECT * FROM #PersonContactInfo


--Optimised Code

--Create temp table
CREATE TABLE #PersonContactInfo
(
	   BusinessEntityID INT
      ,Title VARCHAR(8)
      ,FirstName VARCHAR(50)
      ,MiddleName VARCHAR(50)
      ,LastName VARCHAR(50)
	  ,PhoneNumber VARCHAR(25)
	  ,PhoneNumberTypeID VARCHAR(25)
	  ,PhoneNumberType VARCHAR(25)
	  ,EmailAddress VARCHAR(50)
)

INSERT INTO #PersonContactInfo
(
	   BusinessEntityID
      ,Title
      ,FirstName
      ,MiddleName
      ,LastName
)

SELECT
	   BusinessEntityID
      ,Title
      ,FirstName
      ,MiddleName
      ,LastName

FROM AdventureWorks2017.Person.Person


--Add clustered index into #PersonContactInfo
CREATE CLUSTERED INDEX PersonContactInfo_index ON #PersonContactInfo(BusinessEntityID)


--Add PhoneNumber and PhoneNumberTypeID columns with UPDATE
UPDATE A
SET
	PhoneNumber = B.PhoneNumber,
	PhoneNumberTypeID = B.PhoneNumberTypeID

FROM #PersonContactInfo A
	JOIN AdventureWorks2017.Person.PersonPhone B
		ON A.BusinessEntityID = B.BusinessEntityID


--Add nonclustered index on PhoneNumberTypeID
CREATE NONCLUSTERED INDEX PhoneNumberTypeID_index ON #PersonContactInfo(PhoneNumberTypeID)


-- Add PhoneNumberType data 
UPDATE A
SET	PhoneNumberType = B.Name

FROM #PersonContactInfo A
	JOIN AdventureWorks2017.Person.PhoneNumberType B
		ON A.PhoneNumberTypeID = B.PhoneNumberTypeID


-- Add EmailAddress column with UPDATE
UPDATE A
SET	EmailAddress = B.EmailAddress

FROM #PersonContactInfo A
	JOIN AdventureWorks2017.Person.EmailAddress B
		ON A.BusinessEntityID = B.BusinessEntityID

-- See the result
SELECT * FROM #PersonContactInfo

-- Drop table #PersonContactInfo
DROP TABLE #PersonContactInfo


-------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------
-----------------  LOOKUP TABLES -----------------
--------------------------------------------------

/*

Make the temp tables permanent objects on our server.

-=--------------------------------
Probably good to know for an interview
DDL = Data Definition Language commands: pertain to the structure and definition of a table. Includes CREATE, DROP, and TRUNCATE.

DML = Data Manipulation Language commands: manipulates the data within the tables. Includes INSERT, UPDATE, and DELETE
----------------------------------

Benefits of lookup tables:
- Eliminates duplicating efforts by putting frequently used attributes into one place
- Promote data integrity by consolidating into a 'single truth'
- An example is a date table.

*/
--Example of doing a calendar lookup table

--Create the Calendar table
CREATE TABLE AdventureWorks2017.dbo.Calendar
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
SELECT CAST('2011-01-01' AS DATE) as MyDate

UNION ALL

SELECT
	DATEADD(DAY,1,MyDate)
FROM DateSeries
WHERE MyDate < CAST('2019-12-31' AS DATE)
)

--Insert into the Calendar table
INSERT INTO AdventureWorks2017.dbo.Calendar
(
DateValue
)

SELECT
MyDate
FROM DateSeries
OPTION(MAXRECURSION 15000)


--Update some of the other columns now that we have our DateValue column filled
UPDATE AdventureWorks2017.dbo.Calendar
SET
	DayOfWeekNumber = DATEPART(WEEKDAY,DateValue),
	DayOfWeekName = FORMAT(DateValue,'dddd'),
	DayOfMonthNumber = DAY(DateValue),
	MonthNumber = MONTH(DateValue),
	YearNumber = YEAR(DateValue)


--Update the weekend flag 
UPDATE AdventureWorks2017.dbo.Calendar
SET
	WeekendFlag = 	CASE 
					WHEN DayOfWeekName IN ('Saturday','Sunday') 
					THEN 1 
					ELSE 0 
					END


--Update the holiday flag 
UPDATE AdventureWorks2017.dbo.Calendar
SET
	HolidayFlag = 	CASE 
					WHEN DayOfMonthNumber = 1 AND MonthNumber = 1 
					THEN 1 
					ELSE 0 
					END


--Now we've created our Calendar table!
--Let's join it with another table to see what it looks like for sales only on weekend
SELECT
A.*
FROM AdventureWorks2017.Sales.SalesOrderHeader A
	JOIN AdventureWorks2017.dbo.Calendar B
		ON A.OrderDate = B.DateValue

WHERE B.WeekendFlag = 1


-- Query the calendar table to check
SELECT * FROM adventureworks2017.dbo.Calendar


--Use to Truncate the Calendar table
TRUNCATE table AdventureWorks2017.dbo.Calendar


--Use to drop the Calendar table
DROP TABLE AdventureWorks2017.dbo.Calendar


---------------------------------------------------------------------------------------------------------------------------------

--Lookup Tables - Exercises

/*
Exercise 1
Update your calendar lookup table with a few holidays of your choice that always fall on the same day of the year - for example, New Year's.
*/

UPDATE AdventureWorks2017.dbo.Calendar
SET	
	HolidayFlag = 	CASE 
					WHEN (DayOfMonthNumber = 1 AND MonthNumber = 1)
						OR (DayOfMonthNumber = 31 AND MonthNumber = 10)
						OR (DayOfMonthNumber = 24 AND MonthNumber = 12)
						OR (DayOfMonthNumber = 25 AND MonthNumber = 12)
						OR (DayOfMonthNumber = 31 AND MonthNumber = 12)
						OR (DayOfMonthNumber = 1 AND MonthNumber = 4)
						OR (DayOfMonthNumber = 30 AND MonthNumber = 6)
						OR (DayOfMonthNumber = 4 AND MonthNumber = 7)
						OR (DayOfMonthNumber = 11 AND MonthNumber = 11)
						OR (DayOfMonthNumber = 2 AND MonthNumber = 2)
						OR (DayOfMonthNumber = 3 AND MonthNumber = 3)
						OR (DayOfMonthNumber = 14 AND MonthNumber = 3)
					THEN 1 
					ELSE 0 
					END


/*
Exercise 2
Using your updated calendar table, pull all purchasing orders that were made on a holiday. It's fine to simply select all columns via SELECT *.
*/
SELECT
*
FROM Purchasing.PurchaseOrderHeader A
	JOIN Adventureworks2017.dbo.Calendar B
		ON A.OrderDate = B.DateValue

WHERE B.HolidayFlag = 1

/*
Exercise 3
Again using your updated calendar table, now pull all purchasing orders that were made on a holiday that also fell on a weekend.
*/
SELECT
*
FROM Purchasing.PurchaseOrderHeader A
	JOIN Adventureworks2017.dbo.Calendar B
		ON A.OrderDate = B.DateValue

WHERE B.HolidayFlag = 1 
	AND B.WeekendFlag = 1