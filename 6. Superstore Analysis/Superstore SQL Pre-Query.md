### Combine all the tables together & Check the whole dataset.

```sql
SELECT *
FROM Orders AS O
INNER JOIN People AS P ON O.Region = P.Region
LEFT JOIN Returns AS R ON O.[Order ID] = R.[Order ID]
ORDER BY O.[Row ID] ASC;
```

![1  LEFT1](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/c93bbc7c-35f7-4bfb-be40-29a73e97060b)
![2  RIGHT1](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/c273b2cf-08a0-4282-b62e-9efaced39173)

***

### Rename the "Person" column to "SalesPerson" in the "People" table before querying the combined table.

```sql
EXEC sp_rename 'People.Person', 'SalesPerson', 'COLUMN';
```

![3  Person](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/11f71239-5cd8-4449-9c4a-5d06214add0b)
![4  SalesPerson](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/611de166-640e-4294-b034-4a6de399c80f)

***

### Rename the "Region" column to "PeopleRegion" in the "People" table to avoid name duplication, enabling its removal later.

```sql
EXEC sp_rename 'People.Region', 'PeopleRegion', 'COLUMN';
```

![5  Region](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/38656eef-3ec7-4989-9ba4-7fee33e00769)
![6  PeopleRegion](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/9bd300fd-8c2c-44c7-a1b5-ccf19c6916c0)

***

### Rename the "Order ID" column to "OrderIDclone" in the "Returns" table to avoid name duplication, enabling its removal later.

```sql
EXEC sp_rename 'Returns.Order ID', 'OrderIDclone', 'COLUMN';
```

![7  Order ID](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/8c63be44-6eda-4587-8f15-659cbc93ce65)
![8  OrderIDclone](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/09e88479-8f00-46e6-8ab8-0360a825f3b5)

***

### Create a temporary table "CombinedTable" to avoid repeating JOINs & to remove duplicate columns (PeopleRegion, OrderIDclone).

```sql
SELECT *
INTO #CombinedTable
FROM Orders AS O
INNER JOIN People AS P ON O.Region = P.PeopleRegion
LEFT JOIN Returns AS R ON O.[Order ID] = R.[OrderIDclone];
```

### Check the temp table.

```sql
SELECT *
FROM #CombinedTable
ORDER BY [Row ID] ASC;
```

![9  LEFT2](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/9819b315-9a2a-4355-a40e-d6e261054cea)
![10  RIGHT2](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/a198f493-8603-4dab-8dee-1192cb983dfd)

***

### Remove the duplicate "PeopleRegion" column from the combined table.

```sql
ALTER TABLE #CombinedTable
DROP COLUMN PeopleRegion;
```

### Remove the duplicate "OrderIDclone" column from the combined table.

```sql
ALTER TABLE #CombinedTable
DROP COLUMN OrderIDclone;
```

### Check the temp table again.

```sql
SELECT *
FROM #CombinedTable
ORDER BY [Row ID] ASC;
```

![11  LEFT3](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/13bbe038-6125-4088-813f-0ff3f28035f6)
![12  RIGHT3](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/fbcdca49-e388-4499-b7d8-fe51398e6d0d)

***

### The table is ready for querying.

Previous: [Introduction](https://github.com/Jagadish940112/Portfolio-Projects/tree/main/6.%20Superstore%20Analysis)<p align="right">Next: [Superstore SQL Query](https://github.com/Jagadish940112/Portfolio-Projects/blob/main/6.%20Superstore%20Analysis/Superstore%20SQL%20Query.md)</p>
