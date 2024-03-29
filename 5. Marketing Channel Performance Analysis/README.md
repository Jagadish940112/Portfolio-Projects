# Marketing Channel Performance Analysis

![Marketing Channel](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/75df45a6-e12e-4da7-b7c9-524b9bb9587b)

### Business Task:
- Analyze and compare the performance of different marketing channels.

### Tools:
- Google BigQuery

### Data Set:
- Customer acquisition data obtained from [Kaggle](https://www.kaggle.com/datasets/bhanupratapbiswas/customer-lifetime-value-analytics-case-study).

### Columns & Values:
1. customer_id = This column contains the numbers from ***1 to 800***. It represents the ***unique identifiers*** for each customer.

2. channel = This column contains four repeating words: "***email marketing***", "***paid advertising***", "***referral***", and "***social media***". These words represent the different ***marketing channels*** used to acquire customers.

3. cost = This column contains four repeating numbers: ***5.246263271***, ***30.45032721***, ***8.320326732***, and ***9.546325668***. These numbers represent the ***cost*** incurred to acquire customers through each respective marketing channel.

4. conversion_rate = This column contains four repeating numbers: ***0.043822229***, ***0.016341492***, ***0.123144979***, and ***0.167592247***. These numbers represent the ***conversion rates*** achieved for each marketing channel, indicating the proportion of customers who converted into ***revenue-generating customers***.

5. revenue = This column contains numbers ranging from ***500 to 4998***. These numbers represent the ***revenue*** generated by each customer.

* Column 2. channel directly ***affects*** Column 3. cost and Column 4. conversion_rate, meaning
  * IF channel = "***email marketing***", THEN cost = ***5.246263271*** AND conversion_rate = ***0.043822229***.
* Refer the table below for values in **channel**, **cost** and **conversion_rate** columns.

     | customer_id |      channel     |     cost    | conversion_rate | revenue |
     | :---------: | :--------------: | :---------: | :-------------: | :-----: |
     |      3      | email marketing  | 5.246263271 |   0.043822229   |   3164  |
     |      6      | paid advertising | 30.45032721 |   0.016341492   |   3856  |
     |      12     | referral         | 8.320326732 |   0.123144979   |   1455  |
     |      13     | social media     | 9.546325668 |   0.167592247   |   3388  |

### Analysis:

### 0. Preview Data

```sql
SELECT *
FROM Kaggle.customer_acquisition_data
ORDER BY customer_id ASC;
```

**Answer:**

![0. Preview Data](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/ac85b0ab-9983-4e5f-8ad0-2fcfa5144ad3)

The data is in a table form consisting of 5 columns and 800 rows.

***

### 1. What is the total number of customers?

```sql
SELECT
  COUNT(customer_id) AS Total_Customer,
  COUNT(DISTINCT customer_id) AS Unique_Customer
FROM Kaggle.customer_acquisition_data;
```

**Answer:**

![1. Number of Customers](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/d29fb59c-1bb7-414d-911c-d258d886f272)

There are 800 unique customers, all of whom have different numerical customer IDs.

***

### 2. What is the distribution of customers across different marketing channels?
Using Subquery

```sql
SELECT
  channel AS Marketing_Channel,
  COUNT(customer_id) AS Total_Customer,
  ROUND(COUNT(customer_id) * 100 / all_customers.total_count) AS Customer_Percentage
FROM Kaggle.customer_acquisition_data
CROSS JOIN ( /*combine all rows from one table with all rows from another table*/
  SELECT COUNT(customer_id) AS total_count
  FROM Kaggle.customer_acquisition_data
) AS all_customers
GROUP BY channel, all_customers.total_count
ORDER BY Total_Customer DESC;
```

**Answer:**

![2. Customer Distribution](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/06184ae1-947f-43a0-8bbb-18166856b42d)

The distribution of customers acquired across different marketing channels is fairly even, with Email Marketing and Referral taking the lead.

***

### 3. Compare the sum and average cost spent on customer acquisition for each marketing channel.
Using Common Table Experssion (CTE)

```sql
WITH total_sum_avg AS (
  SELECT
    SUM(cost) AS sum_cost,
    AVG(cost) AS avg_cost
  FROM Kaggle.customer_acquisition_data
)
SELECT
  channel AS Marketing_Channel,
  ROUND(SUM(cost)) AS Total_Cost,
  ROUND(SUM(cost) * 100 / total_sum_avg.sum_cost) AS Total_Percentage,
  ROUND(AVG(cost), 2) AS Average_Cost,
  ROUND(AVG(cost) * 100 / total_sum_avg.avg_cost) AS Average_Percentage
FROM Kaggle.customer_acquisition_data
CROSS JOIN total_sum_avg
GROUP BY channel, total_sum_avg.sum_cost, total_sum_avg.avg_cost
ORDER BY Total_Cost DESC, Average_Cost DESC;
```

**Answer:**

![3. Customer Acquisition Cost](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/ae61dacd-8f9e-4598-81a4-960efba9a564)

Paid Advertising accounted for 56% of all customer acquisition costs, with its average cost 232% higher than the total average.

Email Marketing accounted for only 11% of all customer acquisition costs, with its average cost 40% lower than the total average.

***

### 4. Compare the average conversion rate between each marketing channel.

```sql
SELECT
  channel,
  AVG(conversion_rate) AS Avg_Convert_Rate
FROM Kaggle.customer_acquisition_data
GROUP BY channel
ORDER BY Avg_Convert_Rate DESC;
```

**Answer:**

![4. Conversion Rate](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/98f0d33f-3392-4f80-a54d-afc8ca860544)

The conversion rate represents the **proportion** of customers who have taken the desired action (e.g., making a purchase) out of the ***total** number of customers acquired through each marketing channel.

***total** includes customers who did not make a purchase, for whom data is not available in the table.

***

### 5. What is the sum and average revenue for each marketing channel?
Using Window functions SUM() and AVG() with the OVER () clause

```sql
SELECT
  channel AS Marketing_Channel,
  SUM(revenue) AS Total_Revenue,
  ROUND(SUM(revenue) * 100 / SUM(SUM(revenue)) OVER ()) AS Total_Percentage,
  /*The inner SUM(revenue) calculates the sum of revenue for each marketing channel,
    and the outer SUM() as the window function calculates the sum of the revenue for all marketing channels without grouping*/
  ROUND(AVG(revenue)) AS Average_Revenue,
  ROUND(AVG(revenue) * 100 / AVG(AVG(revenue)) OVER (), 1) AS Average_Percentage
  /*0.1% increase in Average_Percentage compared to result from Google Sheets due to larger decimal points processing in SQL*/
FROM Kaggle.customer_acquisition_data
GROUP BY channel
ORDER BY channel ASC;
```

**Answer:**

![5. Revenue](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/25673bc6-2899-4746-b7e6-9ad8c0ae200b)

The total revenue brought by each marketing channel is close to one another, except for Social Media, slightly behind.

As for average revenue, both Email Marketing and Paid Advertising are tied for first place.

***

### 6. Calculate the average Return on Investment (ROI) for each marketing channel.
ROI = (revenue - cost) / cost

```sql
SELECT
  channel AS Marketing_Channel,
  ROUND(AVG((revenue - cost) / cost)) AS Average_ROI
FROM Kaggle.customer_acquisition_data
GROUP BY channel
ORDER BY Average_ROI DESC;
```

**Answer:**

![6. ROI](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/b4187dc7-37c6-4a7a-acd6-1304f5b049c7)

Email Marketing yielded the highest average ROI, while Paid Advertising did the opposite.

The ROIs are expressed in ratios instead of percentages due to their large numbers.

Even Paid Advertising resulted in an average 9200% ROI if converted to percentage.

This is because the ROIs above accounted for the whole customer lifetime instead of a certain time period.

***

### 7. Identify which marketing channel brought in the most high-value customers based on Customer Lifetime Value (CLV).
CLV = (revenue - cost) * conversion_rate / cost

Value = High, if CLV > average CLV <br>
Value = Medium, if CLV = average CLV <br>
Value = Low, if CLV < average CLV

```sql
WITH CTE AS (
  SELECT *,
    CASE
      WHEN CLV > Average_CLV THEN 'High'
      WHEN CLV = Average_CLV THEN 'Medium'
      WHEN CLV < Average_CLV THEN 'Low'
    END AS Value
  FROM (
    SELECT *,
      (revenue - cost) * conversion_rate / cost AS CLV,
      AVG((revenue - cost) * conversion_rate / cost) OVER () AS Average_CLV
    FROM Kaggle.customer_acquisition_data
  )
)
SELECT
  channel AS Marketing_Channel,
  COUNT(CASE WHEN Value = 'High' THEN 1 END) AS High,
  --COUNT(CASE WHEN Value = 'Medium' THEN 1 END) AS Medium,/*Zero Count for Medium for all Channel*/
  COUNT(CASE WHEN Value = 'Low' THEN 1 END) AS Low
FROM CTE
GROUP BY channel
ORDER BY High DESC;
```

How the CTE looks like:

![7a. CTE](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/721a329e-b9fe-4682-baf5-e381fb3660f8)

**Answer:**

![7b. CLV](https://github.com/Jagadish940112/Portfolio-Projects/assets/116116336/6120a887-17a7-4ea6-baff-bba695782809)

Referral brought in the most high-value customers, followed closely by Social Media.

Paid Advertising had zero high-value customers due to its high customer acquisition cost, which drove CLV lower than the average.

***

shorter version of above query to get the same result but without creating "Value" column

```sql
SELECT
  channel AS Marketing_Channel,
  COUNT(CASE WHEN CLV > Average_CLV THEN 1 END) AS High,
  --COUNT(CASE WHEN CLV = Average_CLV THEN 1 END) AS Medium,/*Zero Count for Medium for all Channel*/
  COUNT(CASE WHEN CLV < Average_CLV THEN 1 END) AS Low
FROM (
  SELECT *,
    (revenue - cost) * conversion_rate / cost AS CLV,
    AVG((revenue - cost) * conversion_rate / cost) OVER () AS Average_CLV
  FROM Kaggle.customer_acquisition_data
) AS subquery
GROUP BY channel
ORDER BY High DESC;
```

***

# THE END
