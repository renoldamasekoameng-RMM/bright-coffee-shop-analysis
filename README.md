**Bright Coffee Shop: Sales Analysis (Jan–Jun 2023)**
**Project Overview**

Bright Coffee Shop operates three stores in New York: Astoria, Hell's Kitchen and Lower Manhattan. This project analyses six months of transaction data (January to June 2023) to help leadership understand what is selling, where and when, and how the business is trending. All monetary values are in Rands (R).

**Business questions answered**
  •	How much revenue, how many units and how many transactions did the shop generate?
  •	Which stores, products and categories drive revenue?
  •	How does performance change by month, day of the week and time of day?
  •	Is any store or day underperforming?
  
**Headline numbers
Metric	Value**
Total revenue	R698,812
Units sold	214,470
Transactions	149,116
Average transaction value	R4.69

**Methodology**
Data inspection (Databricks SQL). Checked the stores, the date range, business hours, the number of products and the product categories in the raw table.
Data cleaning. unit_price was stored as text with comma decimals (e.g. 3,1). It was converted with CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)).
Feature engineering. A cleaned table, sales_final, was built with CREATE OR REPLACE TABLE ... AS SELECT. It adds these columns: 
  o	revenue (quantity × unit price)
  o	day_name and month_name
  o	day_classification (Weekday or Weekend)
  o	time_classification (Morning, Afternoon or Evening)
  o	time_bucket (30-minute windows)
Aggregation. A grouped summary query gives sales, units, unique products, revenue and average transaction value by date, store, category and time window.
   
**Additional analysis**
    o	Average transaction value per store
    o	Units sold by product type
    o	Peak trading hours
    o	Monthly revenue trend with month-over-month change
    o	Weekend vs weekday performance
    o	Category mix shift by month
  	
Visualisation. The results were exported to CSV and built into dashboards in Excel, Looker Studio and Power BI. A CEO presentation was planned from the findings.
   
**The full script is in bright_coffee_shop_final.sql. It runs top to bottom, and every statement ends with a semicolon.
Key Insights**
  •	Strong growth. Monthly revenue rose from R81,678 in January to R166,486 in June, an increase of about 104%. February was the only dip (R76,145).
  •	Coffee and Tea are the core. Coffee (R269,952, 38.6%) and Tea (R196,406, 28.1%) together make up about 67% of revenue. Bakery (R82,316), Drinking Chocolate (R72,416) and Coffee Beans (R40,085) follow.
  •	Stores are evenly matched. Hell's Kitchen leads with R236,511, then Astoria (R232,244) and Lower Manhattan (R230,057). The gap between the highest and lowest is under 3%, so no store is underperforming.
  •	Days of the week are flat. Revenue is spread evenly across all seven days. Saturday is the lowest at R96,894, but not by much.
  
**Recommendations**
  •	Protect and promote Coffee and Tea, since they carry the business.
  •	Plan staffing and stock for continued growth, as sales have roughly doubled in six months.
  •	Look at growing the smaller categories (Bakery, Drinking Chocolate, Coffee Beans) to reduce reliance on two categories.
  
**Tools Used**
**Tool	Purpose**
  Databricks SQL	Data inspection, cleaning, feature engineering and analysis queries
  Excel	Pivot tables, charts, KPI cards and a store location map dashboard
  Looker Studio	Interactive dashboard
  Power BI	Interactive dashboard (using a custom coffee theme)
  PowerPoint	CEO presentation
  
**Repository Contents**
•	bright_coffee_shop_final.sql: full SQL script
•	Excel_Dashboard.xlsx: Excel dashboard
•	Power BI file (.pbix) and Looker Studio dashboard link



