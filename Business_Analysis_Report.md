# E-Commerce Business Analysis Report

**Period analysed:** Jan 2025 – Oct 2026  |  **Tools:** SQL (MySQL 8.0 command-line client)
**Revenue definition:** quantity × unit price on *Delivered* orders only (Cancelled and Returned excluded)
**Data note:** the dataset is synthetic (generated with `generate_data.py`, seed 42) because external downloads were unavailable. Swap in a real dataset (e.g. Olist) by loading it into the same four tables.

## Headline numbers

| Metric | Value |
|---|---|
| Delivered orders | 8,260 |
| Customers who purchased | 1,225 of 1,500 |
| Total revenue | $1,180,529 |
| Average order value | $142.92 |
| Cancelled / Returned orders | 4.2% / 4.1% |

## 1. Which product generates the highest revenue?

**Smart Watch — $127,559** (641 units, ~$46.5K gross profit).

| Rank | Product | Category | Revenue |
|---|---|---|---|
| 1 | Smart Watch | Electronics | $127,559 |
| 2 | Vacuum Cleaner | Home & Kitchen | $101,135 |
| 3 | 4K Action Camera | Electronics | $98,489 |
| 4 | Running Shoes | Fashion | $56,610 |
| 5 | Air Fryer | Home & Kitchen | $55,447 |

**Insight:** the top three high-ticket products earn 28% of revenue. Revenue is driven by price, not volume: Running Shoes sold more units (666) than the Smart Watch (641) but earned less than half as much.

## 2. Who are the top 10 customers?

| # | Customer | Country | Orders | Total spent |
|---|---|---|---|---|
| 1 | Arjun Kim (ID 1475) | Germany | 271 | $39,943 |
| 2 | Zoe Clark (394) | USA | 161 | $23,669 |
| 3 | Emma Sharma (1204) | USA | 127 | $18,685 |
| 4 | Emma Khan (501) | Canada | 121 | $16,821 |
| 5 | Ananya Lee (1194) | Germany | 105 | $15,798 |
| 6 | Aarav Singh (1273) | USA | 99 | $14,341 |
| 7 | Carlos Wang (319) | USA | 102 | $13,972 |
| 8 | Jack Miller (54) | USA | 97 | $13,737 |
| 9 | Priya Johnson (1161) | USA | 91 | $12,819 |
| 10 | Emma Brown (1247) | India | 74 | $12,042 |

**Insight:** the top 10 customers generate **15.4%** of revenue, so revenue is concentrated but not dangerously. Customer #6 (Aarav Singh) has not ordered since Feb 2026 and is the most valuable lapsed customer (see Q5).
*Caveat:* order counts this high (271 orders) would be unusual in real retail and are an artefact of the synthetic data; in a real dataset, check these accounts for resellers or duplicate accounts.

## 3. Which month has the highest sales?

**December 2025 — $100,237**, with October 2026 virtually tied at $100,124.

- Revenue grew from ~$1.9K (Jan 2025) to ~$100K per month by Oct 2026, mainly because the customer base was still being built (customers join over time).
- Nov–Dec 2025 shows a clear holiday spike (+66% in Nov), then a **52% drop in Jan 2026**.
- Oct 2026 matching the 2025 holiday peak suggests that, with Nov/Dec 2026 still to come, this year's holiday season should set a new record.
- Calendar-month totals rank October first ($154K), but this is skewed: Jan–Oct appear twice in the data while Nov and Dec appear only once. Use the month-by-month trend (query 3a) for decisions.

## 4. Which category has the lowest sales?

**Books — $23,637 (2.0% of revenue).**

| Category | Revenue | % of total | Gross margin |
|---|---|---|---|
| Electronics | $376,942 | 31.9% | 38.0% |
| Home & Kitchen | $290,685 | 24.6% | 43.9% |
| Fashion | $243,465 | 20.6% | 40.2% |
| Sports & Outdoors | $122,145 | 10.3% | 38.8% |
| Beauty | $88,310 | 7.5% | 36.3% |
| Toys & Games | $35,345 | 3.0% | 36.8% |
| Books | $23,637 | 2.0% | 43.5% |

**Insight:** Books and Toys & Games together are only 5% of revenue. Books has a healthy 43.5% margin but low prices ($12–$35), so volume would need to rise a lot to matter. Best use: bundle books as low-cost add-ons to Electronics and Home & Kitchen orders. Home & Kitchen has the best margin of the large categories (43.9%) and is the strongest candidate for extra marketing spend.

## 5. Who hasn't purchased anything recently?

"Recently" = no delivered order in the 90 days before the latest order date (31 Oct 2026).

| Segment | Customers | Share |
|---|---|---|
| Active (last 90 days) | 785 | 52.3% |
| Lapsed (90+ days) | 440 | 29.3% |
| Never purchased | 275 | 18.3% |

**Highest-value lapsed customers (win-back priority):** Aarav Singh ($14,341; 255 days inactive), Fatima Kim ($3,756; 203 days), Daniel Miller ($3,112; 108 days), Jack Lopez ($3,110; 357 days), Noah Singh ($2,426; 185 days). The full top-20 list is in query 5a.

**Insight:** nearly half of all registered customers (47.7%) are not currently buying.

## Recommendations

1. **Protect and promote top products.** Keep Smart Watch, Vacuum Cleaner and 4K Action Camera in stock ahead of Nov–Dec and feature them in holiday campaigns.
2. **Run a win-back campaign** on the 440 lapsed customers, starting with the highest-value ones listed in query 5a.
3. **Convert the 275 registered-but-never-purchased customers** with a first-order discount.
4. **Grow Books and Toys through bundling** rather than standalone promotion.
5. **Plan for seasonality:** the January drop (-52%) is predictable, so schedule promotions and inventory for it.
6. **Look into the 4.1% return rate** by product to find quality or description problems.

## Project files

| File | Purpose |
|---|---|
| `mysql_01_schema.sql` | Creates the `ecommerce` database and tables |
| `mysql_02_data.sql` | Loads all data (about 25,000 rows) |
| `mysql_03_queries.sql` | All analysis queries |
| `Business_Analysis_Report.md` | This report |
| `generate_data.py`, `make_mysql_data.py` | Optional: regenerate the dataset |

**To run (Windows Command Prompt):**
```
cd "C:\Users\admin\OneDrive\Personal_Details\Data_Analysis_Projects\Advanced SQL Business Analysis"
mysql -u root -p
```
Then, inside the `mysql>` prompt:
```
source mysql_01_schema.sql
source mysql_02_data.sql
source mysql_03_queries.sql
```
