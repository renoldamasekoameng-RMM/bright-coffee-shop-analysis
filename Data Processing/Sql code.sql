-- ============================================
-- PART 1: TECHNICAL DATA INSPECTION
-- ============================================

-- Preview the data
SELECT *
FROM `bright_coffee_shop`.`assignment1`.`1790097946203_bright_coffee_shop_sales_dataset`
LIMIT 100;

-- How many stores do we have
SELECT DISTINCT store_location
FROM `bright_coffee_shop`.`assignment1`.`1790097946203_bright_coffee_shop_sales_dataset`;

-- What is the period of this data
SELECT MIN(transaction_date) AS start_dt,
       MAX(transaction_date) AS last_dt
FROM `bright_coffee_shop`.`assignment1`.`1790097946203_bright_coffee_shop_sales_dataset`;

-- What are the business hours of the shop
SELECT MIN(transaction_time) AS opening_time,
       MAX(transaction_time) AS closing_time
FROM `bright_coffee_shop`.`assignment1`.`1790097946203_bright_coffee_shop_sales_dataset`;

-- How many products are we selling per store
-- How many products are we selling per store
SELECT store_location,
       COUNT(DISTINCT product_id) AS number_of_products
FROM `bright_coffee_shop`.`assignment1`.`1790097946203_bright_coffee_shop_sales_dataset`
GROUP BY store_location
ORDER BY number_of_products DESC;

-- How many different products are we selling in total
SELECT COUNT(DISTINCT product_id) AS number_of_products
FROM `bright_coffee_shop`.`assignment1`.`1790097946203_bright_coffee_shop_sales_dataset`;

-- What are the different product categories we have
SELECT DISTINCT product_category, product_type, product_detail
FROM `bright_coffee_shop`.`assignment1`.`1790097946203_bright_coffee_shop_sales_dataset`
ORDER BY product_category;
 -- ============================================
-- PART 2: MAIN ANALYSIS QUERY
-- ============================================

WITH cleaned AS (
    SELECT 
        *,
        -- 1. Fix price format: replace comma with dot and convert to a number
        CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)) AS unit_price_clean,

        -- 2. Total amount per line = price x quantity
        transaction_qty * CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)) AS total_amount,

        -- 3. 30-minute time bucket, e.g. 07:00 - 07:30
        CONCAT(
            LPAD(HOUR(TO_TIMESTAMP(transaction_time, 'HH:mm:ss')), 2, '0'), ':',
            CASE WHEN MINUTE(TO_TIMESTAMP(transaction_time, 'HH:mm:ss')) < 30 THEN '00' ELSE '30' END,
            ' - ',
            CASE 
                WHEN MINUTE(TO_TIMESTAMP(transaction_time, 'HH:mm:ss')) < 30 
                    THEN CONCAT(LPAD(HOUR(TO_TIMESTAMP(transaction_time, 'HH:mm:ss')), 2, '0'), ':30')
                ELSE CONCAT(LPAD(HOUR(TO_TIMESTAMP(transaction_time, 'HH:mm:ss')) + 1, 2, '0'), ':00')
            END
        ) AS time_bucket
    FROM `bright_coffee_shop`.`assignment1`.`1790097946203_bright_coffee_shop_sales_dataset`
)

SELECT 
    transaction_date,--From Original table
    DAYNAME(transaction_date)   AS day_name,--DAYNAME gives the name of the specific day
    MONTHNAME(transaction_date) AS month_name,--MONTHNAME gives the name of the specific month
    time_bucket,
    COUNT(transaction_id) AS number_of_sales,--COUNT gives the number of rows
    SUM(transaction_qty) AS units_sold,--SUM gives the sum of the column
    COUNT(DISTINCT product_id) AS unique_products,--COUNT gives the number of rows
    SUM(total_amount) AS revenue,

-- Classify each transaction as a weekend or weekday based on the day name
    CASE WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END AS day_classification,

  -- Group each transaction into a part of the day based on the time it occurred
    CASE 
        WHEN transaction_time BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN transaction_time BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        WHEN transaction_time BETWEEN '18:00:00' AND '20:59:59' THEN 'Evening'
        ELSE 'Other'
    END AS time_classification,

-- Store and product attributes used for grouping and analysis
    store_location,-- where the sale took place
    product_category,-- broad product group (e.g. Coffee, Tea)
    product_type,-- more specific grouping within the category
    product_detail -- the individual product description

FROM cleaned

GROUP BY 
-- Date and month of the transaction
    transaction_date,
    day_name,
-- Store and product attributes (must match the SELECT list)
    month_name,
    time_bucket,
    day_classification,
    time_classification,
    store_location,
    product_category,
    product_type,
    product_detail;

-- ============================================
-- PART 3: ADDITIONAL ANALYSIS
-- ============================================
-- Average transaction value
-- Average transaction value per store
SELECT 
    store_location,
    SUM(total_amount) / COUNT(DISTINCT transaction_id) AS avg_transaction_value
FROM bright_coffee_shop.assignment1.cleaned_sales
GROUP BY store_location
ORDER BY avg_transaction_value DESC;

-- Monthly revenue trend with month-over-month change

-- Monthly revenue trend with month-over-month change
SELECT 
    DATE_TRUNC('month', transaction_date)  AS month_start,   -- used for correct date ordering
    MONTHNAME(transaction_date)            AS month_name,
    SUM(total_amount)                      AS revenue,
    LAG(SUM(total_amount)) OVER (ORDER BY DATE_TRUNC('month', transaction_date)) AS previous_month_revenue,
    ROUND(
        (SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY DATE_TRUNC('month', transaction_date)))
        / LAG(SUM(total_amount)) OVER (ORDER BY DATE_TRUNC('month', transaction_date)) * 100, 1
    ) AS pct_change_vs_previous_month
FROM bright_coffee_shop.assignment1.cleaned_sales
GROUP BY DATE_TRUNC('month', transaction_date), MONTHNAME(transaction_date)
ORDER BY month_start;

-- Weekend vs weekday performance

SELECT 
    CASE WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END AS day_classification,
    COUNT(DISTINCT transaction_date)   AS trading_days,
    SUM(total_amount)                  AS total_revenue,
    COUNT(DISTINCT transaction_id)     AS total_transactions,
    SUM(transaction_qty)               AS units_sold,
    ROUND(SUM(total_amount) / COUNT(DISTINCT transaction_date), 2)       AS avg_revenue_per_day,
    ROUND(COUNT(DISTINCT transaction_id) / COUNT(DISTINCT transaction_date), 1) AS avg_transactions_per_day,
    ROUND(SUM(total_amount) / COUNT(DISTINCT transaction_id), 2)         AS avg_transaction_value
FROM bright_coffee_shop.assignment1.cleaned_sales
GROUP BY day_classification;
