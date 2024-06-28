-- Combine all the tables together & Check the whole dataset.
SELECT *
FROM Orders AS O
INNER JOIN People AS P ON O.Region = P.Region
LEFT JOIN Returns AS R ON O.[Order ID] = R.[Order ID]
ORDER BY O.[Row ID] ASC;

-- Rename the "Person" column to "SalesPerson" in the "People" table before querying the combined table.
EXEC sp_rename 'People.Person', 'SalesPerson', 'COLUMN';

-- Rename the "Region" column to "PeopleRegion" in the "People" table to avoid name duplication, enabling its removal later.
EXEC sp_rename 'People.Region', 'PeopleRegion', 'COLUMN';

-- Rename the "Order ID" column to "OrderIDclone" in the "Returns" table to avoid name duplication, enabling its removal later.
EXEC sp_rename 'Returns.Order ID', 'OrderIDclone', 'COLUMN';

-- Create a temporary table "CombinedTable" to avoid repeating JOINs & to remove duplicate columns (PeopleRegion, OrderIDclone).
SELECT *
INTO #CombinedTable
FROM Orders AS O
INNER JOIN People AS P ON O.Region = P.PeopleRegion
LEFT JOIN Returns AS R ON O.[Order ID] = R.[OrderIDclone];

-- Check the temp table.
SELECT *
FROM #CombinedTable
ORDER BY [Row ID] ASC;

-- Remove the duplicate "PeopleRegion" column from the combined table.
ALTER TABLE #CombinedTable
DROP COLUMN PeopleRegion;

-- Remove the duplicate "OrderIDclone" column from the combined table.
ALTER TABLE #CombinedTable
DROP COLUMN OrderIDclone;

-- Check the temp table again.
SELECT *
FROM #CombinedTable
ORDER BY [Row ID] ASC;

-- The table is ready for querying.