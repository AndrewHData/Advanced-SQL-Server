/*
----------------------------------------------------
Introducing Window Functions With OVER - Exercises
----------------------------------------------------
Exercise 1

Create a query with the following columns:
FirstName and LastName, from the Person.Person table**
JobTitle, from the HumanResources.Employee table**
Rate, from the HumanResources.EmployeePayHistory table**
A derived column called "AverageRate" that returns the average of all values in the "Rate" column, in each row

**All the above tables can be joined on BusinessEntityID

*/

SELECT
	p.FirstName,
	p.LastName,
	hr.JobTitle,
	hrpay.Rate,
	AVG(hrpay.Rate) OVER() as 'Average Pay'
FROM Person.Person p
JOIN HumanResources.Employee hr on p.BusinessEntityID = hr.BusinessEntityID
JOIN HumanResources.EmployeePayHistory hrpay on hrpay.BusinessEntityID = p.BusinessEntityID
group by 	p.FirstName,
			p.LastName,
			hr.JobTitle,
			hrpay.Rate
;

/*
Exercise 2
Enhance your query from Exercise 1 by adding a derived column called
"MaximumRate" that returns the largest of all values in the "Rate" column, in each row.
*/

SELECT
	p.FirstName,
	p.LastName,
	hr.JobTitle,
	hrpay.Rate,
	AVG(hrpay.Rate) OVER() as 'Average Pay',
	MAX(hrpay.Rate) OVER() as 'Maximum Rate'
FROM Person.Person p
JOIN HumanResources.Employee hr on p.BusinessEntityID = hr.BusinessEntityID
JOIN HumanResources.EmployeePayHistory hrpay on hrpay.BusinessEntityID = p.BusinessEntityID
group by 	p.FirstName,
			p.LastName,
			hr.JobTitle,
			hrpay.Rate

/*
Exercise 3
Enhance your query from Exercise 2 by adding a derived column called
"DiffFromAvgRate" that returns the result of the following calculation:
An employees's pay rate, MINUS the average of all values in the "Rate" column.
*/

SELECT
	p.FirstName,
	p.LastName,
	hr.JobTitle,
	hrpay.Rate,
	AVG(hrpay.Rate) OVER() as 'Average Pay',
	MAX(hrpay.Rate) OVER() as 'Maximum Rate',
	(hrpay.Rate - AVG(hrpay.Rate) OVER()) as 'DiffFromAvgRate'
FROM Person.Person p
JOIN HumanResources.Employee hr on p.BusinessEntityID = hr.BusinessEntityID
JOIN HumanResources.EmployeePayHistory hrpay on hrpay.BusinessEntityID = p.BusinessEntityID
group by 	p.FirstName,
			p.LastName,
			hr.JobTitle,
			hrpay.Rate

/*
Exercise 4
Enhance your query from Exercise 3 by adding a derived column called
"PercentofMaxRate" that returns the result of the following calculation:
An employees's pay rate, DIVIDED BY the maximum of all values in the "Rate" column, times 100.
*/

SELECT
	p.FirstName,
	p.LastName,
	hr.JobTitle,
	hrpay.Rate,
	AVG(hrpay.Rate) OVER() as 'Average Pay',
	MAX(hrpay.Rate) OVER() as 'Maximum Rate',
	(hrpay.Rate - AVG(hrpay.Rate) OVER()) as 'DiffFromAvgRate',
	(hrpay.Rate / (MAX(hrpay.Rate) OVER())) * 100 as 'PercentofMaxRate'
FROM Person.Person p
JOIN HumanResources.Employee hr on p.BusinessEntityID = hr.BusinessEntityID
JOIN HumanResources.EmployeePayHistory hrpay on hrpay.BusinessEntityID = p.BusinessEntityID
group by 	p.FirstName,
			p.LastName,
			hr.JobTitle,
			hrpay.Rate

/*
----------------------------
PARTITION BY - Exercises
----------------------------
Exercise 1
Create a query with the following columns:
“Name” from the Production.Product table, which can be alised as “ProductName”
“ListPrice” from the Production.Product table
“Name” from the Production. ProductSubcategory table, which can be alised as “ProductSubcategory”*
“Name” from the Production.ProductCategory table, which can be alised as “ProductCategory”**
*Join Production.ProductSubcategory to Production.Product on “ProductSubcategoryID”
**Join Production.ProductCategory to ProductSubcategory on “ProductCategoryID”
All the tables can be inner joined, and you do not need to apply any criteria.
*/

select
	pp.Name as ProductName,
	pp.ListPrice,
	ps.Name as ProductSubCategory,
	pc.Name as ProductCategory
from Production.Product pp
join Production.ProductSubcategory ps on pp.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc on pc.ProductCategoryID = ps.ProductCategoryID

/*
Exercise 2
Enhance your query from Exercise 1 by adding a derived column called
"AvgPriceByCategory " that returns the average ListPrice for the product category in each given row.
*/

select
	pp.Name as ProductName,
	pp.ListPrice,
	ps.Name as ProductSubCategory,
	pc.Name as ProductCategory,
	AVG(pp.ListPrice) OVER(PARTITION BY pc.Name) as AvgPriceByCategory
from Production.Product pp
join Production.ProductSubcategory ps on pp.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc on pc.ProductCategoryID = ps.ProductCategoryID

/*Exercise 3
Enhance your query from Exercise 2 by adding a derived column called
"AvgPriceByCategoryAndSubcategory" that returns the average ListPrice for the product category AND subcategory in each given row.
*/

select
	pp.Name as ProductName,
	pp.ListPrice,
	ps.Name as ProductSubCategory,
	pc.Name as ProductCategory,
	AVG(pp.ListPrice) OVER(PARTITION BY pc.Name) as AvgPriceByCategory,
	AVG(pp.ListPrice) OVER(PARTITION BY pc.Name,ps.Name) as AvgPriceByCategoryAndSubcategory
from Production.Product pp
join Production.ProductSubcategory ps 
	on pp.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc 
	on pc.ProductCategoryID = ps.ProductCategoryID

/*
Exercise 4:
Enhance your query from Exercise 3 by adding a derived column called
"ProductVsCategoryDelta" that returns the result of the following calculation:
A product's list price, MINUS the average ListPrice for that product’s category.
*/

select
	pp.Name as ProductName,
	pp.ListPrice,
	ps.Name as ProductSubCategory,
	pc.Name as ProductCategory,
	AVG(pp.ListPrice) OVER(PARTITION BY pc.Name) as AvgPriceByCategory,
	AVG(pp.ListPrice) OVER(PARTITION BY pc.Name,ps.Name) as AvgPriceByCategoryAndSubcategory,
	ProductVsCategoryDelta = pp.ListPrice - (AVG(pp.ListPrice) OVER(PARTITION BY pc.Name))
from Production.Product pp
join Production.ProductSubcategory ps 
	on pp.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc 
	on pc.ProductCategoryID = ps.ProductCategoryID

/*
----------------------------
ROW_NUMBER Exercises
----------------------------
Create a query with the following columns (feel free to borrow your code from Exercise 1 of the PARTITION BY exercises):

“Name” from the Production.Product table, which can be alised as “ProductName”
“ListPrice” from the Production.Product table
“Name” from the Production. ProductSubcategory table, which can be alised as “ProductSubcategory”*
“Name” from the Production. Category table, which can be alised as “ProductCategory”**
*Join Production.ProductSubcategory to Production.Product on “ProductSubcategoryID”
**Join Production.ProductCategory to ProductSubcategory on “ProductCategoryID”
All the tables can be inner joined, and you do not need to apply any criteria.

*/

select
	pp.Name as ProductName,
	pp.ListPrice,
	ps.Name as ProductSubCategory,
	pc.Name as ProductCategory
from Production.Product pp
join Production.ProductSubcategory ps on pp.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc on pc.ProductCategoryID = ps.ProductCategoryID

/*
Exercise 2
Enhance your query from Exercise 1 by adding a derived column called
"Price Rank " that ranks all records in the dataset by ListPrice, in descending order. 
That is to say, the product with the most expensive price should have a rank of 1, and the product with the least expensive price should have a rank equal to the number of records in the dataset.
*/

select
	pp.Name as ProductName,
	pp.ListPrice,
	ps.Name as ProductSubCategory,
	pc.Name as ProductCategory,
	'Price Rank' = ROW_NUMBER() OVER(PARTITION BY pp.ListPrice ORDER BY pp.ListPrice desc)
from Production.Product pp
join Production.ProductSubcategory ps on pp.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc on pc.ProductCategoryID = ps.ProductCategoryID

/*
Exercise 3
Enhance your query from Exercise 2 by adding a derived column called
"Category Price Rank" that ranks all products by ListPrice – within each category - in descending order. 
In other words, every product within a given category should be ranked relative to other products in the same category.
*/

select
	pp.Name as ProductName,
	pp.ListPrice,
	ps.Name as ProductSubCategory,
	pc.Name as ProductCategory,
	'Price Rank' = ROW_NUMBER() OVER(PARTITION BY pp.ListPrice ORDER BY pp.ListPrice desc),
	[Category Price Rank] = ROW_NUMBER() OVER (PARTITION BY pc.Name ORDER BY pp.ListPrice desc)
from Production.Product pp
join Production.ProductSubcategory ps on pp.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc on pc.ProductCategoryID = ps.ProductCategoryID

/*
Exercise 4
Enhance your query from Exercise 3 by adding a derived column called
"Top 5 Price In Category" that returns the string “Yes” if a product has one of the top 5 list prices in its product category, and “No” if it does not. 
You can try incorporating your logic from Exercise 3 into a CASE statement to make this work.
*/

select
	pp.Name as ProductName,
	pp.ListPrice,
	ps.Name as ProductSubCategory,
	pc.Name as ProductCategory,
	'Price Rank' = ROW_NUMBER() OVER(PARTITION BY pp.ListPrice ORDER BY pp.ListPrice desc),
	[Category Price Rank] = ROW_NUMBER() OVER (PARTITION BY pc.Name ORDER BY pp.ListPrice desc),
	[Top 5 Price In Category] = CASE 
								WHEN (
									ROW_NUMBER() OVER (PARTITION BY pc.Name ORDER BY pp.ListPrice desc))
									<=5 
								THEN 'Yes' 
								ELSE 'No' 
								END
from Production.Product pp
join Production.ProductSubcategory ps on pp.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc on pc.ProductCategoryID = ps.ProductCategoryID

/*
----------------------------------------
RANK and DENSE_RANK Exercises
----------------------------------------

Exercise 1
Using your solution query to Exercise 4 from the ROW_NUMBER exercises as a starting point, add a derived column called “Category Price Rank With Rank” that uses the RANK function to rank all products by ListPrice – within each category - in descending order.
Observe the differences between the “Category Price Rank” and “Category Price Rank With Rank” fields.
*/

select
	pp.Name as ProductName,
	pp.ListPrice,
	ps.Name as ProductSubCategory,
	pc.Name as ProductCategory,
	'Price Rank' = ROW_NUMBER() OVER(PARTITION BY pp.ListPrice ORDER BY pp.ListPrice desc),
	[Category Price Rank] = ROW_NUMBER() OVER (PARTITION BY pc.Name ORDER BY pp.ListPrice desc),
	[Category Price Rank with Rank] = RANK() OVER(PARTITION BY pc.Name ORDER BY pp.ListPrice desc)
from Production.Product pp
join Production.ProductSubcategory ps on pp.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc on pc.ProductCategoryID = ps.ProductCategoryID

/*
Exercise 2
Modify your query from Exercise 2 by adding a derived column called "Category Price Rank With Dense Rank" that that uses the DENSE_RANK function to rank all products by ListPrice – within each category - in descending order. 
Observe the differences among the “Category Price Rank”, “Category Price Rank With Rank”, and “Category Price Rank With Dense Rank” fields.
*/

select
	pp.Name as ProductName,
	pp.ListPrice,
	ps.Name as ProductSubCategory,
	pc.Name as ProductCategory,
	'Price Rank' = ROW_NUMBER() OVER(PARTITION BY pp.ListPrice ORDER BY pp.ListPrice desc),
	[Category Price Rank] = ROW_NUMBER() OVER (PARTITION BY pc.Name ORDER BY pp.ListPrice desc),
	[Category Price Rank with Rank] = RANK() OVER(PARTITION BY pc.Name ORDER BY pp.ListPrice desc),
	[Category Price Rank with Rank] = DENSE_RANK() OVER(PARTITION BY pc.Name ORDER BY pp.ListPrice desc),
	[Top 5 Price In Category] = CASE 
								WHEN (
									ROW_NUMBER() OVER (PARTITION BY pc.Name ORDER BY pp.ListPrice desc))
									<=5 
								THEN 'Yes' 
								ELSE 'No' 
								END

from Production.Product pp
join Production.ProductSubcategory ps	on pp.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc		on pc.ProductCategoryID = ps.ProductCategoryID

/*
Exercise 3
Examine the code you wrote to define the “Top 5 Price In Category” field back in the ROW_NUMBER exercises. 
Now that you understand the differences among ROW_NUMBER, RANK, and DENSE_RANK, consider which of these functions would be most appropriate to return a true top 5 products by price, assuming we want to see the top 5 distinct prices AND we want “ties” (by price) to all share the same rank.
*/

-- My answer is	DENSE_RANK

select
	pp.Name as ProductName,
	pp.ListPrice,
	ps.Name as ProductSubCategory,
	pc.Name as ProductCategory,
	'Price Rank' = ROW_NUMBER() OVER(PARTITION BY pp.ListPrice ORDER BY pp.ListPrice desc),
	[Category Price Rank] = ROW_NUMBER() OVER (PARTITION BY pc.Name ORDER BY pp.ListPrice desc),
	[Category Price Rank with Rank] = RANK() OVER(PARTITION BY pc.Name ORDER BY pp.ListPrice desc),
	[Category Price Rank with Rank] = DENSE_RANK() OVER(PARTITION BY pc.Name ORDER BY pp.ListPrice desc),
	[Top 5 Price In Category] = CASE 
								WHEN (
									DENSE_RANK() OVER (PARTITION BY pc.Name ORDER BY pp.ListPrice desc))
									<=5 
								THEN 'Yes' 
								ELSE 'No' 
								END
from Production.Product pp
join Production.ProductSubcategory ps	on pp.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc		on pc.ProductCategoryID = ps.ProductCategoryID

/*
----------------------------------------
LEAD and LAG Exercises
----------------------------------------
Exercise 1
Create a query with the following columns:
“PurchaseOrderID” from the Purchasing.PurchaseOrderHeader table
“OrderDate” from the Purchasing.PurchaseOrderHeader table
“TotalDue” from the Purchasing.PurchaseOrderHeader table
“Name” from the Purchasing.Vendor table, which can be aliased as “VendorName”*
*Join Purchasing.Vendor to Purchasing.PurchaseOrderHeader on BusinessEntityID = VendorID

Apply the following criteria to the query:
Order must have taken place on or after 2013
TotalDue must be greater than $500
*/
SELECT
	PurchaseOrderID,
	OrderDate,
	TotalDue,
	v.Name as [VendorName]
FROM Purchasing.PurchaseOrderHeader poh
JOIN Purchasing.Vendor v
	ON poh.VendorID = v.BusinessEntityID
WHERE YEAR(OrderDate) >= 2013
	AND TotalDue > 500


/*
Exercise 2
Modify your query from Exercise 1 by adding a derived column called
"PrevOrderFromVendorAmt", that returns the “previous” TotalDue value (relative to the current row) within the group of all orders with the same vendor ID. We are defining “previous” based on order date.
*/
SELECT
	PurchaseOrderID,
	OrderDate,
	TotalDue,
	v.Name as [VendorName],
	LAG([TotalDue],1) OVER (PARTITION BY v.Name ORDER BY [OrderDate] ASC) as PrevOrderFromVendorAmt
FROM Purchasing.PurchaseOrderHeader poh
JOIN Purchasing.Vendor v
	ON poh.VendorID = v.BusinessEntityID
WHERE YEAR(OrderDate) >= 2013
	AND TotalDue > 500

/*
Exercise 3
Modify your query from Exercise 2 by adding a derived column called
"NextOrderByEmployeeVendor", that returns the “next” vendor name (the “name” field from Purchasing.Vendor) within the group of all orders that have the same EmployeeID value in Purchasing.PurchaseOrderHeader. Similar to the last exercise, we are defining “next” based on order date.
*/

SELECT
	PurchaseOrderID,
	OrderDate,
	v.Name as [VendorName],
	LAG([TotalDue],1) OVER (PARTITION BY v.Name ORDER BY [OrderDate] ASC) as PrevOrderFromVendorAmt,
	TotalDue,
	LEAD(TotalDue,1) OVER (PARTITION BY v.Name ORDER BY [OrderDate] ASC) as NextOrderFromVendorAmt
FROM Purchasing.PurchaseOrderHeader poh
JOIN Purchasing.Vendor v
	ON poh.VendorID = v.BusinessEntityID
WHERE YEAR(OrderDate) >= 2013
	AND TotalDue > 500


/*
Exercise 4
Modify your query from Exercise 3 by adding a derived column called "Next2OrderByEmployeeVendor" that returns, within the group of all orders that have the same EmployeeID, the vendor name offset TWO orders into the “future” relative to the order in the current row. 

The code should be very similar to Exercise 3, but with an extra argument passed to the Window Function used.
*/

SELECT
	PurchaseOrderID,
	OrderDate,
	v.Name as [VendorName],
	LAG([TotalDue],1) OVER (PARTITION BY v.Name ORDER BY [OrderDate] ASC) as PrevOrderFromVendorAmt,
	TotalDue,
	LEAD(TotalDue,1) OVER (PARTITION BY v.Name ORDER BY [OrderDate] ASC) as NextOrderFromVendorAmt,
	LEAD(TotalDue,2) OVER (PARTITION BY v.Name ORDER BY [OrderDate] ASC) as NextTwoOrdersFromVendorAmt
FROM Purchasing.PurchaseOrderHeader poh
JOIN Purchasing.Vendor v
	ON poh.VendorID = v.BusinessEntityID
WHERE YEAR(OrderDate) >= 2013
	AND TotalDue > 500

