# Advanced SQL Business Analysis

SQL analysis of an e-commerce dataset (1,500 customers, 9,000 orders) using **MySQL 8.0**.

## Business questions answered
- Which product generates the highest revenue? **Smart Watch ($127,559)**
- Who are the top 10 customers? **Top customer: Arjun Kim ($39,943)**
- Which month has the highest sales? **December 2025 ($100,237)**
- Which category has the lowest sales? **Books ($23,637)**
- Who hasn't purchased recently? **440 lapsed customers, 275 never purchased**

## Files
- `mysql_01_schema.sql` - creates the database and tables
- `mysql_02_data.sql` - loads the data
- `mysql_03_queries.sql` - all analysis queries
- `Business_Analysis_Report.md` - full findings and recommendations
- `generate_data.py` - script that generated the synthetic dataset

## How to run
1. Open the MySQL 8.0 command line client: `mysql -u root -p`
2. Run `source mysql_01_schema.sql`
3. Run `source mysql_02_data.sql`
4. Run `source mysql_03_queries.sql`

## Skills used
SQL, JOINs, CTEs, window functions (LAG, ROW_NUMBER), aggregations, business analysis
