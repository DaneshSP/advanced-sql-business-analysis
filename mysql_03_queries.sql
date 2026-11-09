-- =====================================================================
-- E-Commerce Business Analysis Queries (MySQL 8.0)
-- Revenue definition: quantity * unit_price on orders with status = 'Delivered'
-- (Cancelled and Returned orders are excluded.)
-- =====================================================================
USE ecommerce;


-- ---------------------------------------------------------------------
-- Q0. Data sanity check / headline KPIs
-- ---------------------------------------------------------------------
SELECT
    COUNT(DISTINCT o.order_id)                                   AS delivered_orders,
    COUNT(DISTINCT o.customer_id)                                AS active_customers,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)                   AS total_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price)
          / COUNT(DISTINCT o.order_id), 2)                       AS avg_order_value,
    MIN(o.order_date)                                            AS first_order,
    MAX(o.order_date)                                            AS last_order
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Delivered';


-- ---------------------------------------------------------------------
-- Q1. Which product generates the highest revenue? (top 10)
-- ---------------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity)                                           AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)                 AS revenue,
    ROUND(SUM(oi.quantity * (oi.unit_price - p.unit_cost)), 2) AS gross_profit
FROM order_items oi
JOIN orders   o ON o.order_id   = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;


-- ---------------------------------------------------------------------
-- Q2. Who are the top 10 customers (by revenue)?
-- ---------------------------------------------------------------------
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)             AS customer_name,
    c.country,
    COUNT(DISTINCT o.order_id)                         AS orders_placed,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)         AS total_spent,
    MAX(o.order_date)                                  AS last_order_date
FROM customers c
JOIN orders      o  ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
ORDER BY total_spent DESC
LIMIT 10;


-- ---------------------------------------------------------------------
-- Q3. Which month has the highest sales?
-- ---------------------------------------------------------------------
-- 3a. Monthly revenue trend with month-over-month growth
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m')             AS month,
        SUM(oi.quantity * oi.unit_price)               AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    month,
    ROUND(revenue, 2)                                                     AS revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
          / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1)             AS mom_growth_pct
FROM monthly
ORDER BY month;

-- 3b. Best month overall
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m')                 AS month,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)         AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY revenue DESC
LIMIT 1;

-- 3c. Seasonality: revenue by calendar month across years
SELECT
    MONTH(o.order_date)                                AS month_number,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)         AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY MONTH(o.order_date)
ORDER BY revenue DESC;


-- ---------------------------------------------------------------------
-- Q4. Which category has the lowest sales?
-- ---------------------------------------------------------------------
SELECT
    p.category,
    SUM(oi.quantity)                                            AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)                  AS revenue,
    ROUND(100.0 * SUM(oi.quantity * oi.unit_price)
          / SUM(SUM(oi.quantity * oi.unit_price)) OVER (), 1)   AS pct_of_total,
    ROUND(100.0 * SUM(oi.quantity * (oi.unit_price - p.unit_cost))
          / SUM(oi.quantity * oi.unit_price), 1)                AS gross_margin_pct
FROM order_items oi
JOIN orders   o ON o.order_id   = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY revenue ASC;          -- first row = lowest-selling category


-- ---------------------------------------------------------------------
-- Q5. Who hasn't purchased anything recently?
--     "Recently" = no delivered purchase in the 90 days before the
--     latest order date in the data (keeps the query reproducible).
-- ---------------------------------------------------------------------
-- 5a. Lapsed customers (bought before, but not in the last 90 days)
WITH ref AS (
    SELECT MAX(order_date) AS as_of FROM orders
),
last_purchase AS (
    SELECT
        o.customer_id,
        MAX(o.order_date)                              AS last_order_date,
        COUNT(DISTINCT o.order_id)                     AS lifetime_orders,
        SUM(oi.quantity * oi.unit_price)               AS lifetime_value
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)             AS customer_name,
    c.email,
    lp.last_order_date,
    DATEDIFF(r.as_of, lp.last_order_date)              AS days_since_last_order,
    lp.lifetime_orders,
    ROUND(lp.lifetime_value, 2)                        AS lifetime_value
FROM customers c
JOIN last_purchase lp ON lp.customer_id = c.customer_id
CROSS JOIN ref r
WHERE lp.last_order_date < DATE_SUB(r.as_of, INTERVAL 90 DAY)
ORDER BY lp.lifetime_value DESC          -- highest-value lapsed customers first (win-back priority)
LIMIT 20;

-- 5b. Summary: lapsed vs. active vs. never purchased
WITH ref AS (
    SELECT MAX(order_date) AS as_of FROM orders
),
last_purchase AS (
    SELECT customer_id, MAX(order_date) AS last_order_date
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
),
labelled AS (
    SELECT
        CASE
            WHEN lp.customer_id IS NULL                                        THEN 'Never purchased'
            WHEN lp.last_order_date < DATE_SUB(r.as_of, INTERVAL 90 DAY)       THEN 'Lapsed (90+ days)'
            ELSE 'Active (last 90 days)'
        END AS customer_status
    FROM customers c
    LEFT JOIN last_purchase lp ON lp.customer_id = c.customer_id
    CROSS JOIN ref r
)
SELECT
    customer_status,
    COUNT(*)                                           AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_customers
FROM labelled
GROUP BY customer_status
ORDER BY customers DESC;


-- ---------------------------------------------------------------------
-- BONUS A. Revenue by country
-- ---------------------------------------------------------------------
SELECT
    c.country,
    COUNT(DISTINCT c.customer_id)                      AS customers,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)         AS revenue
FROM customers c
JOIN orders      o  ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
WHERE o.status = 'Delivered'
GROUP BY c.country
ORDER BY revenue DESC;

-- BONUS B. Order status mix (cancellation / return rate)
SELECT
    status,
    COUNT(*)                                           AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM orders
GROUP BY status
ORDER BY orders DESC;

-- BONUS C. Top-10 customers' share of total revenue (concentration)
WITH cust AS (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS spent
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
),
ranked AS (
    SELECT spent, ROW_NUMBER() OVER (ORDER BY spent DESC) AS rn FROM cust
)
SELECT
    ROUND(100.0 * SUM(CASE WHEN rn <= 10 THEN spent ELSE 0 END) / SUM(spent), 1) AS top10_pct_of_revenue
FROM ranked;
