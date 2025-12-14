/* ============================================================
   PRODUCT SALES & PROFIT MINI PROJECT
   File: product_profit_project.sql
   Description:
     - Create simple ecommerce tables
     - Insert sample data
     - Calculate product profit & profit margin
     - Rank products by profit margin (highest to lowest)
   ============================================================ */

-- 1. DROP TABLES IF THEY EXIST (for re-run safety)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;

-- 2. CREATE TABLES
CREATE TABLE products (
    product_id        INT PRIMARY KEY,
    product_name      VARCHAR(100),
    cost_of_goods_sold DECIMAL(10,2)  -- unit cost
);

CREATE TABLE orders (
    order_id   INT PRIMARY KEY,
    order_date DATE
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id      INT,
    product_id    INT,
    quantity      INT,
    unit_price    DECIMAL(10,2),      -- selling price per unit
    FOREIGN KEY (order_id)  REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 3. INSERT SAMPLE DATA
INSERT INTO products (product_id, product_name, cost_of_goods_sold) VALUES
(1, 'Mouse',        200.00),
(2, 'Keyboard',     400.00),
(3, 'Monitor',     4500.00),
(4, 'Headphones',   800.00);

INSERT INTO orders (order_id, order_date) VALUES
(101, '2025-01-01'),
(102, '2025-01-02'),
(103, '2025-01-03');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 101, 1, 3,  350.00),  -- Mouse
(2, 101, 2, 1,  650.00),  -- Keyboard
(3, 102, 3, 2, 6500.00),  -- Monitor
(4, 103, 1, 1,  320.00),  -- Mouse
(5, 103, 4, 4, 1200.00);  -- Headphones

/* ============================================================
   4. LOGICAL QUERY: PRODUCT PROFIT & PROFIT MARGIN
   ============================================================ */

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price)                AS total_revenue,
    SUM(oi.quantity * p.cost_of_goods_sold)         AS total_cogs,
    SUM(oi.quantity * oi.unit_price)
      - SUM(oi.quantity * p.cost_of_goods_sold)     AS total_profit,
    CASE
        WHEN SUM(oi.quantity * oi.unit_price) = 0 THEN 0
        ELSE (
            (SUM(oi.quantity * oi.unit_price)
             - SUM(oi.quantity * p.cost_of_goods_sold))
            / SUM(oi.quantity * oi.unit_price)
        )
    END                                             AS profit_margin,
    RANK() OVER (
        ORDER BY
            CASE
                WHEN SUM(oi.quantity * oi.unit_price) = 0 THEN 0
                ELSE (
                    (SUM(oi.quantity * oi.unit_price)
                     - SUM(oi.quantity * p.cost_of_goods_sold))
                    / SUM(oi.quantity * oi.unit_price)
                )
            END DESC
    )                                               AS margin_rank
FROM
    products p
JOIN
    order_items oi ON p.product_id = oi.product_id
JOIN
    orders o       ON o.order_id   = oi.order_id
GROUP BY
    p.product_id, p.product_name
ORDER BY
    profit_margin DESC;
