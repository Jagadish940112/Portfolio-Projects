-- 1. Querying, Joining & Sorting Data
-- Create a temporary table "CombinedTable" to avoid repeating JOINs & to remove duplicate columns (PeopleRegion, OrderIDclone).
SELECT *
INTO #CombinedTable
FROM Orders AS O
INNER JOIN People AS P
	ON O.Region = P.PeopleRegion
LEFT JOIN Returns AS R
	ON O.[Order ID] = R.[OrderIDclone]
ORDER BY [Row ID] ASC;

-- Remove the duplicate "PeopleRegion" column from the combined table.
ALTER TABLE #CombinedTable
DROP COLUMN PeopleRegion;

-- Remove the duplicate "OrderIDclone" column from the combined table.
ALTER TABLE #CombinedTable
DROP COLUMN OrderIDclone;

-- 2. Working with NULLs
-- Find out how many orders were returned.
-- A "Yes" in the Returned column indicates that an order was returned; otherwise, it is marked as "NULL".
-- The Order ID column contains duplicates. Use DISTINCT to count unique orders.
SELECT COUNT(DISTINCT [Order ID]) AS Total_Orders_Returned
FROM #CombinedTable
WHERE Returned IS NOT NULL;

-- Replacing NULLs with other values is typically done using NULLIF(), COALESCE(), or CASE statement.
SELECT Returned,
	COALESCE(Returned, 'No') AS edited_Returned
FROM #CombinedTable;

-- 3. Data Type Conversion
-- Change "Order Date" data type from datetime to date using CAST().
SELECT [Order Date],
	CAST([Order Date] AS date) AS edited_Order_Date
FROM #CombinedTable
ORDER BY [Row ID] DESC;

-- 4. Data Aggregation
-- Aggregate functions (COUNT, SUM, AVG, MIN, MAX), GROUP BY, HAVING
-- Find all the Sub-Categories that have made at least 100k in total sales.
SELECT [Sub-Category],
	ROUND(SUM(Sales), 2) AS Total_Sales
FROM #CombinedTable
GROUP BY [Sub-Category]
HAVING SUM(Sales) >= 100000
ORDER BY Total_Sales DESC;

-- 5. Handling Dates
-- Date functions (DATEDIFF, EXTRACT, DATE_PART, DATE_NAME, DATE_TRUNC, TO_CHAR)
-- Group the number of orders by their order processing days.
SELECT
	DATEDIFF(DAY, [Order Date], [Ship Date]) AS Order_Processing_Days,
	COUNT(DISTINCT [Order ID]) AS Unique_Order_Count
FROM
	#CombinedTable
GROUP BY
	DATEDIFF(DAY, [Order Date], [Ship Date])
ORDER BY
	Order_Processing_Days;

-- Find the total sales for each month across all years.
SELECT
	DATENAME(MONTH, [Order Date]) AS Month,
	ROUND(SUM(Sales), 2) AS Total_Sales
FROM
	#CombinedTable
GROUP BY
	DATENAME(MONTH, [Order Date]),
	DATEPART(MONTH, [Order Date])
ORDER BY
	DATEPART(MONTH, [Order Date]);

-- 6. Handling Text
-- String functions (CONCAT or ||, SUBSTRING, LENGTH, REPLACE, TRIM, POSITION, UPPER & LOWER, REGEXP_REPLACE, REGEXP_MATCHES, REGEXP_SPLIT_TO_ARRAY, LEFT & RIGHT)
-- Find out whether the words 'Apple' or 'iPhone' are mentioned in the Product Name column.
SELECT
	[Row ID],
	[Product Name],
	CASE WHEN CHARINDEX('Apple', [Product Name]) > 0 THEN 'Yes' ELSE 'No' END AS Apple,
	CASE WHEN CHARINDEX('iPhone', [Product Name]) > 0 THEN 'Yes' ELSE 'No' END AS iPhone
	       -- CHARINDEX() = This function performs a case-insensitive search.
FROM #CombinedTable
WHERE [Product Name] LIKE '%Apple%' OR [Product Name] LIKE '%iPhone%'
ORDER BY [Row ID];

-- 7. Ranking Data
-- ROW_NUMBER(), RANK(), DENSE_RANK()
-- Rank the Sub-Categories from most profitable to least within each Category.
SELECT
	Category,
	[Sub-Category],
	ROUND(SUM(Profit), 2) AS Total_Profit,
	DENSE_RANK() OVER(PARTITION BY Category ORDER BY SUM(Profit) DESC) AS Profit_Rank
FROM
	#CombinedTable
GROUP BY
	Category, [Sub-Category];

-- 8. Window Functions
-- Calculate the order interval, in days, for each customer.
SELECT
	[Order ID],
	[Order Date],
	[Customer Name],
	LAG([Order Date], 1) OVER (PARTITION BY [Customer Name] ORDER BY [Order Date]) AS Previous_Order_Date,
	DATEDIFF(DAY, LAG([Order Date], 1) OVER (PARTITION BY [Customer Name] ORDER BY [Order Date]), [Order Date]) AS Order_Interval_Days
	--------------LAG([Order Date], 1) OVER (PARTITION BY [Customer Name] ORDER BY [Order Date]) = Previous_Order_Date----------------
FROM
	#CombinedTable
GROUP BY
	[Order ID],
	[Order Date],
	[Customer Name]
ORDER BY
	[Customer Name],
	[Order Date];

-- Find the total profits for each Sub-Category and its corresponding Category.
SELECT
	[Sub-Category],
	SUM(Profit) AS Sub_Category_Profit,
	Category,
	SUM(SUM(Profit)) OVER(PARTITION BY Category) AS Category_Profit
FROM
	#CombinedTable
GROUP BY
	[Sub-Category],
	Category;
/*
In the context of calculating the total profit for each category using a window function,
the ORDER BY clause is unnecessary because we are only interested in the sum partitioned by the category,
not in any running totals or ordered computations.
The ORDER BY clause is typically used in window functions when you need to calculate cumulative totals,
rankings, or other calculations that depend on the order of rows within each partition.
*/

-- 9. CTE & Subquery
-- Find the first order for each customer.

-- CTE to get the first unique order ID for each customer
WITH FirstOrder AS (
	SELECT DISTINCT
		FIRST_VALUE([Order ID]) OVER(PARTITION BY [Customer Name] ORDER BY [Order Date]) AS FirstOrderID
	FROM
		#CombinedTable
)

-- Main query to retrieve the details of the first orders
SELECT
	[Order ID],
	[Order Date],
	[Customer Name],
	[Product Name],
	[Sub-Category],
	Category
FROM
	#CombinedTable
WHERE
	[Order ID] IN (SELECT FirstOrderID FROM FirstOrder)
	-- Subquery acts as a filter to get values from the CTE
ORDER BY
	[Customer Name],
	[Order Date];
-- Results may contain duplicate 'Order IDs' due to different 'Product Names'.
-- Same `Order ID` is assigned to each `Product Name` in a single order.
