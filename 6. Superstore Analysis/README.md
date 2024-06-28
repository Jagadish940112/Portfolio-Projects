# Superstore Analysis

<img src="https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/a457a77a-e947-4284-bc29-e523576b69d5" alt="Superstore" width="1100" height="550">

### Objective:
- Analyze the Superstore dataset using Main SQL Concepts.

### Tool:
- Microsoft SQL Server Management Studio 18

### Data Set:
- Superstore Sales sample data obtained from [Tableau](https://public.tableau.com/app/learn/sample-data).

### Columns & Values:
From Orders table:
1. Row ID = Numbers from ***1*** to ***9994***, representing ***unique identifiers*** for each row.

2. Order ID = ***Unique identifiers*** for each ***order*** placed, formatted as CA-YEAR-XXXXXX(Numbers) or US-YEAR-XXXXXX(Numbers), e.g., US-2016-151862.

3. Order Date = Order dates ranging from 3/1/2014 to 30/12/2017.

4. Ship Date = Shipping dates ranging from 7/1/2014 to 5/1/2018.

5. Ship Mode = Shipping modes for each order, which can either be "Same Day", "First Class", "Second Class", or "Standard Class".

6. Customer ID = ***Unique identifiers*** for each ***customer***, formatted as (First Name Initial)(Middle/Last Name Initial)-XXXXX(Numbers), e.g., CG-12520.

7. Customer Name = Customer names formatted as FirstName MiddleName(Optional) LastName, e.g., Darrin Van Huff.

8. Segment = Customers can be classified as "Consumer", "Corporate", or "Home Office".

9. Country = United States only.

10. City = Cities within a state where orders were placed in a Superstore branch.

11. State = States within the country where orders were placed in a Superstore branch.

12. Postal Code = Postal codes within a city where orders were placed in a Superstore branch.

13. Region = Each state is assigned to a region — "Central", "East", "South", or "West" — based on its geographical location.

14. Product ID = ***Unique identifiers*** assigned to each ***product***, formatted as XXX(Category Initial)-XX(Sub-Category Initial)-XXXXXXXX(Numbers), e.g., FUR-BO-10001798.

15. Category = Each sub-category falls into one of the following categories: "Furniture", "Office Supplies", or "Technology".

16. Sub-Category = Each product is classified into one of 17 sub-categories.

17. Product Name = Names of the product.

18. Sales = Sales amount of each product, ranging from 0.444 to 22638.48.

19. Quantity = Quantities purchased for each product, ranging from 1 to 14.

20. Discount = Discount provided for each product, expressed as a decimal ranging from 0 to 0.8.

21. Profit = Profit/Loss incurred for each product, ranging from -6599.978 to 8399.976.

From Returns table:
1. Returned = "Yes" only.

2. Order ID = Same as above. Orders that were returned.

From People table:
1. Person = Salesperson responsible for each region.

2. Region = Same as above. Each region is managed by a different person.

### Schema:
<img src="https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/04f96f29-ea7c-4d93-ac3d-fc1247b28de2" alt="Schema" width="1100" height="550">

### Model:
<img src="https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/614ac0ab-a636-44a1-94a1-d69f2c32cd15" alt="Model" width="1100" height="550">

### Combining Tables:
- Use INNER JOIN between Orders & People tables on Region column.
- Use LEFT JOIN between Orders & Returns tables on Order ID column.

### Cleaning Up:
- Rename “Person” column to “SalesPerson” from People table after joining tables.
- Remove/Hide duplicate "Order ID" column from Returns table after joining tables.
- Remove/Hide duplicate "Region" column from People table after joining tables.
