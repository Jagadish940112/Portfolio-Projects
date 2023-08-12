-- 0. Preview Data
SELECT *
FROM Kaggle.customer_acquisition_data
ORDER BY customer_id ASC;

-- 1. What is the total number of customers?
SELECT
  COUNT(customer_id) AS Total_Customer,
  COUNT(DISTINCT customer_id) AS Unique_Customer
FROM Kaggle.customer_acquisition_data;

-- 2. What is the distribution of customers across different marketing channels?
-- Using Subquery
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

-- 3. Compare the sum and average cost spent on customer acquisition for each marketing channel.
-- Using Common Table Experssion (CTE)
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

-- 4. Compare the average conversion rate between each marketing channel.
SELECT
  channel,
  AVG(conversion_rate) AS Avg_Convert_Rate
FROM Kaggle.customer_acquisition_data
GROUP BY channel
ORDER BY Avg_Convert_Rate DESC;

-- 5. What is the sum and average revenue for each marketing channel?
-- Using Window functions SUM() and AVG() with the OVER () clause
SELECT
  channel AS Marketing_Channel,
  SUM(revenue) AS Total_Revenue,
  ROUND(SUM(revenue) * 100 / SUM(SUM(revenue)) OVER ()) AS Total_Percentage,
  /*The inner SUM(revenue) calculates the sum of revenue for each marketing channel,
    and the outer SUM() function in the window function calculates the sum of the revenue for all marketing channels without grouping*/
  ROUND(AVG(revenue)) AS Average_Revenue,
  ROUND(AVG(revenue) * 100 / AVG(AVG(revenue)) OVER (), 1) AS Average_Percentage
  /*0.1% increase in Average_Percentage compared to result from Google Sheets due to larger decimal points processing in SQL*/
FROM Kaggle.customer_acquisition_data
GROUP BY channel
ORDER BY channel ASC;

-- 6. Calculate the average Return on Investment (ROI) for each marketing channel.
-- ROI = (revenue - cost) / cost
SELECT
  channel AS Marketing_Channel,
  ROUND(AVG((revenue - cost) / cost)) AS Average_ROI
FROM Kaggle.customer_acquisition_data
GROUP BY channel
ORDER BY Average_ROI DESC;

-- 7. Identify which marketing channel brought in the most high-value customers based on Customer Lifetime Value (CLV).
-- CLV = (revenue - cost) * conversion_rate / cost

-- Value = High, if CLV > average CLV
-- Value = Medium, if CLV = average CLV
-- Value = Low, if CLV < average CLV

WITH CTE AS (
  SELECT *,
    CASE
      WHEN CLV > Average_CLV THEN 'High'
      WHEN CLV = Average_CLV THEN 'Medium'
      WHEN CLV < Average_CLV THEN 'Low'
    END AS Value
  FROM(
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

-- shorter version of above query to get the same result but without creating "Value" column
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

--THE END--
