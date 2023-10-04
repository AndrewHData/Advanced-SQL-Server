/************  Introducing Subqueries - Exercises  ************/
/*
Exercise 1
Write a query that displays the three most expensive orders, per vendor ID, from the Purchasing.PurchaseOrderHeader table. There should ONLY be three records per Vendor ID, even if some of the total amounts due are identical. "Most expensive" is defined by the amount in the "TotalDue" field.
Include the following fields in your output:
PurchaseOrderID
VendorID
OrderDate
TaxAmt
Freight
TotalDue

Hints:
You will first need to define a field that assigns a unique rank to every purchase order, within each group of like vendor IDs.
You'll probably want to use a Window Function with PARTITION BY and ORDER BY to do this.
The last step will be to apply the appropriate criteria to the field you created with your Window Function.
*/
SELECT
	*
FROM (
	SELECT
		PurchaseOrderID,
		VendorID,
		OrderDate,
		TaxAmt,
		Freight,
		TotalDue,
		Top3ExpensiveOrders = ROW_NUMBER() OVER (PARTITION BY VendorID ORDER BY TotalDue DESC)
	FROM Purchasing.PurchaseOrderHeader oh
	) subquery
WHERE Top3ExpensiveOrders <= 3

/*
Exercise 2
Modify your query from the first problem, such that the top three purchase order amounts are returned, regardless of how many records are returned per Vendor Id.
In other words, if there are multiple orders with the same total due amount, all should be returned as long as the total due amount for these orders is one of the top three.
Ultimately, you should see three distinct total due amounts (i.e., the top three) for each group of like Vendor Ids. 
However, there could be multiple records for each of these amounts.

Hint: Think carefully about how the different ranking functions (ROW_NUMBER, RANK, and DENSE_RANK) work, and which one might be best suited to help you here.
*/
SELECT
	*
FROM (
	SELECT
		PurchaseOrderID,
		VendorID,
		OrderDate,
		TaxAmt,
		Freight,
		TotalDue,
		Top3ExpensiveOrders = DENSE_RANK() OVER (PARTITION BY VendorID ORDER BY TotalDue DESC)
	FROM Purchasing.PurchaseOrderHeader oh
	) subquery
WHERE Top3ExpensiveOrders <= 3

/*
-----------------------------
Scalar Subqueries - Exercises
-----------------------------
Exercise 1
Create a query that displays all rows and the following columns from the AdventureWorks2019.HumanResources.Employee table:
BusinessEntityID
JobTitle
VacationHours
Also include a derived column called "MaxVacationHours" that returns the maximum amount of vacation hours for any one employee, in any given row.
-----------------------------
*/

SELECT
	BusinessEntityID,
	JobTitle,
	VacationHours,
	MaxVacationHours = (SELECT MAX(VacationHours) FROM HumanResources.Employee)
FROM HumanResources.Employee

/*
Exercise 2
Add a new derived field to your query from Exercise 1, which returns the percent an individual employees' vacation hours are, of the maximum vacation hours for any employee. 
For example, the record for the employee with the most vacation hours should have a value of 1.00, or 100%, in this column.

Hints:
You can repurpose your logic from the "MaxVacationHours" for the denominator.
Make sure you multiply at least one side of your equation by 1.0, to ensure the output will be a decimal.
*/

SELECT
	BusinessEntityID,
	JobTitle,
	VacationHours,
	MaxVacationHours = (SELECT MAX(VacationHours) FROM HumanResources.Employee),
	PercentVacationHours = 100 * VacationHours / (SELECT MAX(VacationHours) FROM HumanResources.Employee)
FROM HumanResources.Employee

/*
Exercise 3
Refine your output with a criterion in the WHERE clause that filters out any employees whose vacation hours are less then 80% of the maximum amount of vacation hours for any one employee. In other words, return only employees who have at least 80% as much vacation time as the employee with the most vacation time.

Hint: The query should return 60 rows.
*/
SELECT
	BusinessEntityID,
	JobTitle,
	VacationHours,
	MaxVacationHours = (SELECT MAX(VacationHours) FROM HumanResources.Employee),
	PercentVacationHours = 100 * VacationHours / (SELECT MAX(VacationHours) FROM HumanResources.Employee)
FROM HumanResources.Employee
WHERE 100 * VacationHours / (SELECT MAX(VacationHours) FROM HumanResources.Employee) >=80


/*
--------------------------------------

Correlated Subqueries

--------------------------------------
*/

-- Example for correlated subqueries.
-- How many sales orders in the Sales Order Detail table had an order quantity greater than 1?
-- Ie. We want to do a Count of Sales Orders with OrderQty > 1
-- The query below is an example of what we might be looking at per Sales Order. Run the query
SELECT
	SalesOrderDetailID,
	OrderQty
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43659
-- If you run it, it should return 12 rows. And if you count the number of rows where OrderQty > 1 it should be 6
-- This is where the idea of correlated subqueries comes in.

-- You can put it in SELECT or WHERE clause.
;
-- Following on from the above, this is how we can make it dynamic so we count each Sales Order.
-- The below query gets us what we are looking for:
SELECT
	 SalesOrderID,
	 OrderDate,
	 SubTotal,
	 TaxAmt,
	 Freight,
	 TotalDue,
	 MultiOrderCount =	(
						SELECT
							COUNT(*)
						FROM Sales.SalesOrderDetail b			-- make sure we alias the subquery table. See the b and h
						WHERE b.SalesOrderID = h.SalesOrderID	-- notice the b and h. we kind of join the subquery with outer query.
						AND OrderQty > 1
						)
FROM Sales.SalesOrderHeader h
;

/*
Correlated Subqueries - Exercises
Exercise 1
Write a query that outputs all records from the Purchasing.PurchaseOrderHeader table. Include the following columns from the table:
PurchaseOrderID
VendorID
OrderDate
TotalDue
Add a derived column called NonRejectedItems which returns, for each purchase order ID in the query output, the number of line items from the Purchasing.PurchaseOrderDetail table which did not have any rejections (i.e., RejectedQty = 0). Use a correlated subquery to do this.
*/

SELECT
	PurchaseOrderID,
	NonRejectedItems =	(
						SELECT
							COUNT(*)
						FROM Purchasing.PurchaseOrderDetail b
						WHERE a.PurchaseOrderID = b.PurchaseOrderID
						AND RejectedQty = 0
						)
FROM Purchasing.PurchaseOrderHeader a
;
-- What happens when we don't put in the ids
SELECT
	PurchaseOrderID,
	NonRejectedItems =	(
						SELECT
							COUNT(*)
						FROM Purchasing.PurchaseOrderDetail b
						WHERE RejectedQty = 0
						)
FROM Purchasing.PurchaseOrderHeader a
;

SELECT
	PurchaseOrderID,
	VendorID,
	OrderDate,
	TotalDue
FROM Purchasing.PurchaseOrderHeader a
;
SELECT
	PurchaseOrderID,
	PurchaseOrderDetailID as LineItemID,
	RejectedQty
FROM Purchasing.PurchaseOrderDetail b
order by PurchaseOrderID


/*
Exercise 2
Modify your query to include a second derived field called MostExpensiveItem.
This field should return, for each purchase order ID, the UnitPrice of the most expensive item for that order in the Purchasing.PurchaseOrderDetail table.
Use a correlated subquery to do this as well.
Hint: Think of the most appropriate aggregate function to use in the correlated subquery for this scenario.
*/

SELECT
	PurchaseOrderID,
	VendorID,
	OrderDate,
	TotalDue,
	NonRejectedItems =	(
						SELECT
							COUNT(*)
						FROM Purchasing.PurchaseOrderDetail d -- don't forget to alias the table
						WHERE d.PurchaseOrderID = h.PurchaseOrderID
						AND RejectedQty = 0
						),
	MostExpensiveItem =	(
						SELECT
							ROUND(MAX(UnitPrice),2)
						FROM Purchasing.PurchaseOrderDetail d
						WHERE d.PurchaseOrderID = h.PurchaseOrderID
						)
FROM Purchasing.PurchaseOrderHeader h
;

/*
--------------------------------------

EXISTS and NOT EXISTS

--------------------------------------
*/
-- Use Case It's kind of like joining without having to do a join
-- If the relationship is one-to-one we can use JOIN or EXISTS interchangeably
-- If the relationship is one-to-many, then we will need to consider some things before deciding to use JOIN or EXISTS
-- If we need to show the matches in the output, then it will be best to use JOIN
-- It is best to use EXIST if we want to apply criteria to fields from a secondary table, while making sure that multiple matches in the secondary table won't duplicate data from the primary table.
-- Exists is more like a filter
-- Example: One to many JOIN with criteria
-- What if we want to see orders with a ListPrice of over 10000?
SELECT
	a.SalesOrderID,
	a.OrderDate,
	b.SalesOrderDetailID,
	b.LineTotal

FROM Sales.SalesOrderHeader a
	INNER JOIN Sales.SalesOrderDetail b
		ON	a.SalesOrderID = b.SalesOrderID

WHERE b.LineTotal > 10000
-- Look at SalesOrderID 43683 (first two rows). We are getting every record for each order. 
-- What if we don't care for the salesorderdetail id?


--Example: Using exists to pick only the records we need
-- What if we want to see orders with a ListPrice of over 10000?

SELECT
	a.SalesOrderID,
	a.OrderDate,
	a.TotalDue

FROM Sales.SalesOrderHeader a

WHERE EXISTS	(
				SELECT
				1					-- <-For EXISTS we can put in whatever we like for this line
				FROM Sales.SalesOrderDetail b
				WHERE b.LineTotal > 10000 
				AND a.SalesOrderID = b.SalesOrderID
				)
-- Look at SalesOrderID 43683. Only one row this time!

-- Example: What if we want to see orders where NONE of the items have a ListPrice of over 10000?

-- Using Joins
SELECT
	a.SalesOrderID,
	a.OrderDate,
	b.SalesOrderDetailID,
	b.LineTotal

FROM Sales.SalesOrderHeader a
	INNER JOIN Sales.SalesOrderDetail b
		ON	a.SalesOrderID = b.SalesOrderID

WHERE b.LineTotal < 10000
-- The Join only filters out by the row. So it filters the ITEMS (ie. not the ID) that are under 10000
;

-- Using NOT EXISTS 
-- Can be read as "if there are ANY items less than 10000 then kick the whole ID record out".
SELECT
	a.SalesOrderID,
	a.OrderDate,
	a.TotalDue

FROM Sales.SalesOrderHeader a

WHERE EXISTS	(
				SELECT
				1					-- <-For EXISTS we can put in whatever we like for this line
				FROM Sales.SalesOrderDetail b
				WHERE b.LineTotal < 10000 
				AND a.SalesOrderID = b.SalesOrderID
				)

;

/*----------------------
EXISTS - Exercises
----------------------*/
/*
Exercise 1
Select all records from the Purchasing.PurchaseOrderHeader table such that there is at least one item in the order with an order quantity greater than 500. The individual items tied to an order can be found in the Purchasing.PurchaseOrderDetail table.
Select the following columns:
PurchaseOrderID
OrderDate
SubTotal
TaxAmt
Sort by purchase order ID.
*/

SELECT
	PurchaseOrderID,
	OrderDate,
	SubTotal,
	TaxAmt
FROM Purchasing.PurchaseOrderHeader a
WHERE EXISTS	(
				SELECT
				1
				FROM Purchasing.PurchaseOrderDetail b
				WHERE b.PurchaseOrderID = a.PurchaseOrderID
				AND b.OrderQty > 500
				)
;

/*
Exercise 2
Modify your query from Exercise 1 as follows:
Select all records from the Purchasing.PurchaseOrderHeader table such that there is at least one item in the order with an order quantity greater than 500, AND a unit price greater than $50.00.
Select ALL columns from the Purchasing.PurchaseOrderHeader table for display in your output.
Even if you have aliased this table to enable the use of a JOIN or EXISTS, you can still use the SELECT * shortcut to do this. Assuming you have aliased your table "A", simply use "SELECT A.*" to select all columns from that table.
*/

SELECT
	*
FROM Purchasing.PurchaseOrderHeader a
WHERE EXISTS	(
				SELECT
				1
				FROM Purchasing.PurchaseOrderDetail b
				WHERE b.PurchaseOrderID = a.PurchaseOrderID
				AND OrderQty > 500
				AND UnitPrice > 50
				)
;

/*
Exercise 3
Select all records from the Purchasing.PurchaseOrderHeader table such that NONE of the items within the order have a rejected quantity greater than 0.
Select ALL columns from the Purchasing.PurchaseOrderHeader table using the "SELECT *" shortcut.
*/

SELECT
	*
FROM Purchasing.PurchaseOrderHeader a
WHERE NOT EXISTS	(
					SELECT
					1
					FROM Purchasing.PurchaseOrderDetail b
					WHERE a.PurchaseOrderID = b.PurchaseOrderID
					AND RejectedQty > 0
					)
;

/*
---------------------------------

CROSS-TABBING AND LISTING

FOR XMP PATH With STUFF
Flattening multiple rows into one aka Alteryx's CROSS-TAB

The idea is to change the column to an xml path, which makes it one row. 
The row is a string text, so we can edit it to make it look like a transpose.

---------------------------------
*/
/*
Consider the following example
*/
SELECT
	*
FROM Sales.SalesOrderDetail a
WHERE SalesOrderID = 43659

;

/*
The below is how we can change it to a row
STUFF has 4 arguments:
1. The text we want to stuff into a string
2. Where do we want to start?
3. How many charactes do we want to clip off from the left? This is how we clip off that first comma
4. What is the string we are stuffing our text
*/
SELECT
	STUFF(
		(
		SELECT
			', ' + CAST(CAST(LineTotal as MONEY) AS varchar)
		FROM Sales.SalesOrderDetail a
		WHERE SalesOrderID = 43659
		FOR XML PATH('')   -- change to an xml path
		),
		1,
		2,   -- this argument (third argument in the STUFF function) is where we want to start
		''
		)
;

/* So we can now change the Where SalesorderID, we just change it to correlated sub-query*/
SELECT
	SalesOrderID,
	TotalDue,
	LineTotals = STUFF(
					(
					SELECT
						', ' + CAST(CAST(LineTotal as MONEY) AS varchar)
					FROM Sales.SalesOrderDetail a
					WHERE a.SalesOrderID = b.SalesOrderID
					FOR XML PATH('')   -- change to an xml path
					),
					1,
					2,   -- this argument (third argument in the STUFF function) is where we want to start. In this example, we have a space to consider so we start at 2
					''
					)
				
FROM Sales.SalesOrderHeader b


/*
FOR XML PATH With STUFF - Exercises
Exercise 1
Create a query that displays all rows from the Production.ProductSubcategory table, and includes the following fields:
The "Name" field from Production.ProductSubcategory, which should be aliased as "SubcategoryName"
A derived field called "Products" which displays, for each Subcategory in Production.ProductSubcategory, a semicolon-separated list of all products from Production.Product contained within the given subcategory
Hint: Production.ProductSubcategory and Production.Product are related by the "ProductSubcategoryID" field.
*/

SELECT
	Name as SubcategoryName,
	Products =	STUFF(
					(
					SELECT
						', ' + b.Name
					FROM Production.Product b
					WHERE a.ProductSubcategoryID = b.ProductSubcategoryID
					FOR XML PATH('')
					),
					1,
					2,
					''
				)
FROM Production.ProductSubcategory a
;

SELECT
	Name as SubcategoryName,
	Products = (
					SELECT
						 b.Name
					FROM Production.Product b
					WHERE a.ProductSubcategoryID = b.ProductSubcategoryID
					FOR XML PATH('')
					)
FROM Production.ProductSubcategory a


/*
Exercise 2
Modify the query from Exercise 1 such that only products with a ListPrice value greater than $50 are listed in the "Products" field.
Hint: Assuming you used a correlated subquery in Exercise 1, keep in mind that you can apply additional criteria to it, just as with any other correlated subquery.
NOTE: Your query should still include ALL product subcategories, but only list associated products greater than $50. But since there are certain product subcategories that don't have any associated products greater than $50, some rows in your query output may have a NULL value in the product field.
*/
SELECT
	Name as SubcategoryName,
	Products =	STUFF(
					(
					SELECT
						', ' + b.Name
					FROM Production.Product b
					WHERE a.ProductSubcategoryID = b.ProductSubcategoryID
						AND ListPrice > 50
					FOR XML PATH('')
					),
					1,
					2,
					''
				)
FROM Production.ProductSubcategory a
;

/*
---------------------------------

CROSS-TABBING AND AGGREGATING

Pivot Flattening multiple rows into one aka Alteryx's cross tab with an aggregation (sum, count etc.)

The idea is to transpose into columns to the unique values in the row and aggregate the second column's values per unique value.
Basically a pivot table in MS Excel

We need to specify which values manually we want to see in our output
---------------------------------
*/

------ Part 1 ------
SELECT
	[Bikes],[Clothing],[Accessories],[Components]
FROM(
	SELECT
		ProductCategoryName = d.Name,
		a.LineTotal
	FROM Sales.SalesOrderDetail a
		JOIN Production.Product b
			ON a.ProductID = b.ProductID
		JOIN Production.ProductSubcategory c
			ON b.ProductSubcategoryID = c.ProductSubcategoryID
		JOIN Production.ProductCategory d
			ON c.ProductCategoryID = d.ProductCategoryID
) A  -- the "A" is the alias for the subquery

PIVOT(
	SUM(a.LineTotal) 
	FOR ProductCategoryName IN ([Bikes],[Clothing],[Accessories],[Components])
) B


------ Part 2 ------
-- We can use * instead of select [each column] in the main query
-- Also what happens when we add another column? -- It adds granularity to our Pivot Table
SELECT
	*
FROM(
	SELECT
		ProductCategoryName = d.Name,
		a.LineTotal,
		a.OrderQty -- Adding an extra granularity here
	FROM Sales.SalesOrderDetail a
		JOIN Production.Product b
			ON a.ProductID = b.ProductID
		JOIN Production.ProductSubcategory c
			ON b.ProductSubcategoryID = c.ProductSubcategoryID
		JOIN Production.ProductCategory d
			ON c.ProductCategoryID = d.ProductCategoryID
) A  -- the "A" is the alias for the subquery

PIVOT(
	SUM(a.LineTotal) 
	FOR ProductCategoryName IN ([Bikes],[Clothing],[Accessories],[Components])
) B
Order By 1
;

-- What if we want to alias the OrderQty?
-- Then we will need to list the columns, rather than using *
SELECT
	OrderQty as [Order Quantity], -- Alias it here
	[Bikes],[Clothing],[Accessories],[Components]
FROM(
	SELECT
		ProductCategoryName = d.Name,
		a.LineTotal,
		a.OrderQty
	FROM Sales.SalesOrderDetail a
		JOIN Production.Product b
			ON a.ProductID = b.ProductID
		JOIN Production.ProductSubcategory c
			ON b.ProductSubcategoryID = c.ProductSubcategoryID
		JOIN Production.ProductCategory d
			ON c.ProductCategoryID = d.ProductCategoryID
) A  -- the "A" is the alias for the subquery

PIVOT(
	SUM(a.LineTotal) 
	FOR ProductCategoryName IN ([Bikes],[Clothing],[Accessories],[Components])
) B
Order By 1
;
/*
PIVOT - Exercises
Exercise 1
Using PIVOT, write a query against the HumanResources.Employee table
that summarizes the average amount of vacation time for Sales Representatives, Buyers, and Janitors.
Your output should look like the image below.
*/

SELECT
	*
FROM (
	SELECT
		a.JobTitle,
		a.VacationHours
	FROM HumanResources.Employee a
) A

PIVOT(
	AVG(A.VacationHours)
	FOR A.JobTitle IN ([Sales Representative],[Buyer],[Janitor])
)pivottable

ORDER BY 1
;

/*
Exercise 2
Modify your query from Exercise 1 such that the results are broken out by Gender. Alias the Gender field as "Employee Gender" in your output.
*/

SELECT
	[Employee Gender] = [Gender],
	[Sales Representative],[Buyer],[Janitor]
FROM (
	SELECT
		a.JobTitle,
		a.VacationHours,
		a.Gender
	FROM HumanResources.Employee a
) A

PIVOT(
	AVG(A.VacationHours)
	FOR A.JobTitle IN ([Sales Representative],[Buyer],[Janitor])
)pivottable

ORDER BY 1

;