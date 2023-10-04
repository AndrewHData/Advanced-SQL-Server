--Example of doing a calendar lookup table

--Create the Calendar table
CREATE TABLE calendar
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
SELECT CAST('2011-01-01' AS DATE) as MyDate     --Set your start date 

UNION ALL

SELECT
	DATEADD(DAY,1,MyDate)                       --Currently at 1 day. Change if you need to
FROM DateSeries
WHERE MyDate < CAST('2019-12-31' AS DATE)       --Set your end date
)

--Insert into the DateValue field in the Calendar table
INSERT INTO calendar
(
DateValue
)

SELECT
MyDate
FROM DateSeries
OPTION(MAXRECURSION 15000)


--Update some of the other columns now that we have our DateValue column filled
UPDATE calendar
SET
	DayOfWeekNumber = DATEPART(WEEKDAY,DateValue),
	DayOfWeekName = FORMAT(DateValue,'dddd'),
	DayOfMonthNumber = DAY(DateValue),
	MonthNumber = MONTH(DateValue),
	YearNumber = YEAR(DateValue)


--Update the weekend flag 
UPDATE calendar
SET
	WeekendFlag = 	CASE 
					WHEN DayOfWeekName IN ('Saturday','Sunday') 
					THEN 1 
					ELSE 0 
					END


--Update the holiday flag. Add your own as well.
UPDATE calendar
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


--------------------------------------------------------------------------
-- Useful queries --
--------------------------------------------------------------------------
-- Query the calendar table to check
SELECT * FROM calendar


--Use to Truncate the Calendar table
TRUNCATE table calendar


--Use to drop the Calendar table
DROP TABLE calendar