"""Generate a synthetic e-commerce dataset (reproducible, seed=42)."""
import csv, random
from datetime import date, timedelta

random.seed(42)
OUT = "data/"

# ---- Products -------------------------------------------------------------
catalog = {
    "Electronics": [("Wireless Earbuds", 59), ("Smartphone Case", 15), ("Bluetooth Speaker", 45),
                    ("Laptop Stand", 35), ("USB-C Charger", 25), ("Smart Watch", 199),
                    ("4K Action Camera", 149), ("Gaming Mouse", 49)],
    "Home & Kitchen": [("Air Fryer", 89), ("Coffee Maker", 69), ("Knife Set", 55),
                       ("Vacuum Cleaner", 179), ("Bedding Set", 79), ("Blender", 49)],
    "Fashion": [("Running Shoes", 85), ("Denim Jacket", 70), ("Leather Wallet", 40),
                ("Sunglasses", 60), ("Backpack", 55), ("Wool Sweater", 65)],
    "Sports & Outdoors": [("Yoga Mat", 25), ("Dumbbell Set", 95), ("Camping Tent", 140),
                          ("Water Bottle", 18), ("Cycling Helmet", 50)],
    "Books": [("Data Science Handbook", 35), ("Mystery Novel", 12), ("Cookbook", 22),
              ("Self-Help Bestseller", 15)],
    "Beauty": [("Face Serum", 38), ("Hair Dryer", 55), ("Perfume", 75), ("Makeup Kit", 48)],
    "Toys & Games": [("Building Blocks", 40), ("Board Game", 30), ("RC Car", 65), ("Puzzle 1000pc", 20)],
}
# popularity weight per category (drives order frequency)
cat_weight = {"Electronics": 30, "Home & Kitchen": 18, "Fashion": 22, "Sports & Outdoors": 10,
              "Books": 6, "Beauty": 9, "Toys & Games": 5}

products = []
pid = 1
for cat, items in catalog.items():
    for name, price in items:
        cost = round(price * random.uniform(0.5, 0.7), 2)
        products.append((pid, name, cat, float(price), cost))
        pid += 1

with open(OUT + "products.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["product_id", "product_name", "category", "unit_price", "unit_cost"])
    w.writerows(products)

# ---- Customers ------------------------------------------------------------
first = ["Aarav", "Emma", "Liam", "Olivia", "Noah", "Sophia", "Mason", "Isabella", "Ethan", "Mia",
         "Lucas", "Amelia", "Arjun", "Priya", "Rohan", "Ananya", "Carlos", "Sofia", "Yuki", "Chen",
         "Fatima", "Omar", "Hannah", "Jack", "Zoe", "Daniel", "Grace", "Leo", "Nina", "Sam"]
last = ["Smith", "Johnson", "Patel", "Sharma", "Garcia", "Brown", "Lee", "Kim", "Wang", "Khan",
        "Miller", "Davis", "Singh", "Lopez", "Wilson", "Taylor", "Anderson", "Thomas", "Moore", "Clark"]
cities = [("New York", "USA"), ("Los Angeles", "USA"), ("Chicago", "USA"), ("Toronto", "Canada"),
          ("London", "UK"), ("Manchester", "UK"), ("Mumbai", "India"), ("Bengaluru", "India"),
          ("Sydney", "Australia"), ("Berlin", "Germany"), ("Paris", "France"), ("Dubai", "UAE")]

START, END = date(2025, 1, 1), date(2026, 10, 31)
N_CUST = 1500
customers = []
for cid in range(1, N_CUST + 1):
    fn, ln = random.choice(first), random.choice(last)
    city, country = random.choice(cities)
    signup = START + timedelta(days=random.randint(0, (END - START).days - 30))
    customers.append((cid, fn, ln, f"{fn.lower()}.{ln.lower()}{cid}@example.com", city, country, signup))

with open(OUT + "customers.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["customer_id", "first_name", "last_name", "email", "city", "country", "signup_date"])
    w.writerows(customers)

# ---- Orders + items -------------------------------------------------------
# seasonality multiplier by month (Nov/Dec peak, mild summer bump)
season = {1: .8, 2: .75, 3: .85, 4: .9, 5: .95, 6: 1.0, 7: 1.05, 8: 1.0, 9: .95, 10: 1.1, 11: 1.6, 12: 1.5}
days = [START + timedelta(days=i) for i in range((END - START).days + 1)]
day_w = [season[d.month] * (1.25 if d.weekday() >= 5 else 1.0) for d in days]

prod_by_cat = {}
for p in products:
    prod_by_cat.setdefault(p[2], []).append(p)
cats, cw = list(cat_weight), list(cat_weight.values())

# customer activity: a few heavy buyers; ~20% churned (stop buying early)
cust_w = [random.paretovariate(1.6) for _ in customers]
churn_cutoff = {}
for c in customers:
    if random.random() < 0.22:
        churn_cutoff[c[0]] = END - timedelta(days=random.randint(100, 400))

statuses = ["Delivered"] * 92 + ["Cancelled"] * 4 + ["Returned"] * 4
orders, items = [], []
oid, iid = 1, 1
N_ORDERS = 9000
signup = {c[0]: c[6] for c in customers}
while len(orders) < N_ORDERS:
    c = random.choices(customers, weights=cust_w)[0]
    cid = c[0]
    d = random.choices(days, weights=day_w)[0]
    if d < signup[cid] or (cid in churn_cutoff and d > churn_cutoff[cid]):
        continue
    status = random.choice(statuses)
    orders.append((oid, cid, d, status))
    for _ in range(random.choices([1, 2, 3, 4], weights=[55, 28, 12, 5])[0]):
        cat = random.choices(cats, weights=cw)[0]
        p = random.choice(prod_by_cat[cat])
        qty = random.choices([1, 2, 3], weights=[75, 18, 7])[0]
        items.append((iid, oid, p[0], qty, p[3]))
        iid += 1
    oid += 1

orders.sort(key=lambda r: r[2])
with open(OUT + "orders.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["order_id", "customer_id", "order_date", "status"])
    w.writerows(orders)
with open(OUT + "order_items.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["order_item_id", "order_id", "product_id", "quantity", "unit_price"])
    w.writerows(items)

print(f"customers={len(customers)} products={len(products)} orders={len(orders)} items={len(items)}")
