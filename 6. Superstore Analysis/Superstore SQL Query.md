### 1. Querying, Joining & Sorting Data
- Create a temporary table "CombinedTable" to avoid repeating JOINs & to remove duplicate columns (PeopleRegion, OrderIDclone).
- Refer to [Superstore SQL Pre-Query](https://github.com/Jagadish940112/Portfolio-Projects/blob/main/6.%20Superstore%20Analysis/Superstore%20SQL%20Pre-Query.md)

***

### 2. Working with NULLs
- Find out how many orders were returned.
- A "Yes" in the Returned column indicates that an order was returned; otherwise, it is marked as "NULL".
- The Order ID column contains duplicates. Use DISTINCT to count unique orders.

```sql
SELECT COUNT(DISTINCT [Order ID]) AS Total_Orders_Returned
FROM #CombinedTable
WHERE Returned IS NOT NULL;
```

![2a  Working with NULLS](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/2aa139c7-b438-4cab-8bd3-9277c702a0fc)

- Replacing NULLs with other values is typically done using NULLIF(), COALESCE(), or CASE statement.

```sql
SELECT Returned,
	COALESCE(Returned, 'No') AS edited_Returned
FROM #CombinedTable;
```

![2b  Replacing NULLs](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/1cbbb3e3-afaf-4781-b64b-fd0e34b286b1)

***

### 3. Data Type Conversion
- Change "Order Date" data type from datetime to date using CAST().

```sql
SELECT [Order Date],
	CAST([Order Date] AS date) AS edited_Order_Date
FROM #CombinedTable
ORDER BY [Row ID] DESC;
```

![3  Data Type Conversion](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/78a80c55-6975-4abb-833b-88b9bec68719)

***

### 4. Data Aggregation
- Aggregate functions (COUNT, SUM, AVG, MIN, MAX), GROUP BY, HAVING
- Find all the Sub-Categories that have made at least 100k in total sales.

```sql
SELECT [Sub-Category],
	ROUND(SUM(Sales), 2) AS Total_Sales
FROM #CombinedTable
GROUP BY [Sub-Category]
HAVING SUM(Sales) >= 100000
ORDER BY Total_Sales DESC;
```

![4  Data Aggregation](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/272dfece-710c-45f1-ab52-1ba6772bcd32)

***

### 5. Handling Dates
- Date functions (DATEDIFF, EXTRACT, DATE_PART, DATE_NAME, DATE_TRUNC, TO_CHAR)
- Group the number of orders by their order processing days.

```sql
SELECT
	DATEDIFF(DAY, [Order Date], [Ship Date]) AS Order_Processing_Days,
	COUNT(DISTINCT [Order ID]) AS Unique_Order_Count
FROM
	#CombinedTable
GROUP BY
	DATEDIFF(DAY, [Order Date], [Ship Date])
ORDER BY
	Order_Processing_Days;
```

![5a  Datetime Interval](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/c64e6a90-ba57-4bf2-95b8-9fc4c56acf99)

- Find the total sales for each month across all years.

```sql
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
```

![5b  Datetime Extraction](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/006ca52b-9a6c-4749-b874-6d6606799be2)

***

### 6. Handling Text
- String functions (CONCAT or ||, SUBSTRING, LENGTH, REPLACE, TRIM, POSITION, UPPER & LOWER, REGEXP_REPLACE, REGEXP_MATCHES, REGEXP_SPLIT_TO_ARRAY, LEFT & RIGHT)
- Find out whether the words 'Apple' or 'iPhone' are mentioned in the Product Name column.

```sql
SELECT
	[Row ID],
	[Product Name],
	CASE WHEN CHARINDEX('Apple', [Product Name]) > 0 THEN 'Yes' ELSE 'No' END AS Apple,
	CASE WHEN CHARINDEX('iPhone', [Product Name]) > 0 THEN 'Yes' ELSE 'No' END AS iPhone
	       -- CHARINDEX() = This function performs a case-insensitive search.
FROM #CombinedTable
WHERE [Product Name] LIKE '%Apple%' OR [Product Name] LIKE '%iPhone%'
ORDER BY [Row ID];
```

![6  Handling Text](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/fe025874-3e31-4d73-8ab7-d503318404b8)

***

### 7. Ranking Data
- ROW_NUMBER(), RANK(), DENSE_RANK()
- Rank the Sub-Categories from most profitable to least within each Category.

```sql
SELECT
	Category,
	[Sub-Category],
	ROUND(SUM(Profit), 2) AS Total_Profit,
	DENSE_RANK() OVER(PARTITION BY Category ORDER BY SUM(Profit) DESC) AS Profit_Rank
FROM
	#CombinedTable
GROUP BY
	Category, [Sub-Category];
```

![7  Ranking Data](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/4d1cfb4a-94a0-40f5-bea9-01fc0e64cc11)

***

### 8. Window Functions
- Calculate the order interval, in days, for each customer.

```sql
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
```

![8a  Window Functions, LAG](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/c91d1487-a7ad-47b1-adb3-be555b565945)

- Find the total profits for each Sub-Category and its corresponding Category.

```sql
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
```

![8b  Window Functions, SUM](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/bca47964-3610-4558-8feb-237647e57c63)

In the context of calculating the total profit for each category using a window function, the ORDER BY clause is unnecessary because we are only interested in the sum partitioned by the category, not in any running totals or ordered computations. The ORDER BY clause is typically used in window functions when you need to calculate cumulative totals, rankings, or other calculations that depend on the order of rows within each partition.

***

### 9. CTE & Subquery
- Find the first order for each customer.

```sql
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
```

How the CTE looks like:

![9a  CTE](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/3a5ac5da-2820-4c38-8b66-c73cde724c7f)

Final results:

![9b  Subquery](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/dfa3a40c-379b-4cc0-8361-220fd97fda27)

Results may contain duplicate 'Order IDs' due to different 'Product Names'.<br>
Same 'Order ID' is assigned to each 'Product Name' in a single order.

***

Previous: [Superstore SQL Pre-Query](https://github.com/Jagadish940112/Portfolio-Projects/blob/main/6.%20Superstore%20Analysis/Superstore%20SQL%20Pre-Query.md)
