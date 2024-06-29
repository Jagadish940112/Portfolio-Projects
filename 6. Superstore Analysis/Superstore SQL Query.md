### 2. Working with NULLS
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

### Rename the "Person" column to "SalesPerson" in the "People" table before querying the combined table.
