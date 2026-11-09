-- =====================================================================
-- E-Commerce Analysis: schema (MySQL 8.0)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id  INT PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(120) NOT NULL UNIQUE,
    city         VARCHAR(60),
    country      VARCHAR(60),
    signup_date  DATE NOT NULL
);

CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(60)  NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL,
    unit_cost     DECIMAL(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id     INT PRIMARY KEY,
    customer_id  INT NOT NULL,
    order_date   DATE NOT NULL,
    status       VARCHAR(20) NOT NULL,   -- Delivered / Cancelled / Returned
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id  INT PRIMARY KEY,
    order_id       INT NOT NULL,
    product_id     INT NOT NULL,
    quantity       INT NOT NULL CHECK (quantity > 0),
    unit_price     DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date     ON orders(order_date);
CREATE INDEX idx_items_order     ON order_items(order_id);
CREATE INDEX idx_items_product   ON order_items(product_id);
