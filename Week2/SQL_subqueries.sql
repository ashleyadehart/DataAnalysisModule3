USE coffeeshop_db;

-- =========================================================
-- SUBQUERIES & NESTED LOGIC PRACTICE
-- =========================================================

-- Q1) Scalar subquery (AVG benchmark):
--     List products priced above the overall average product price.
--     Return product_id, name, price.
SELECT
    product_id,
    name,
    price
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
);
-- Q2) Scalar subquery (MAX within category):
--     Find the most expensive product(s) in the 'Beans' category.
--     (Return all ties if more than one product shares the max price.)
--     Return product_id, name, price.
SELECT
    p.product_id,
    p.name,
    p.price
FROM products p
JOIN categories c
    ON p.category_id = c.category_id
WHERE c.name = 'Beans'
  AND p.price = (
        SELECT MAX(p2.price)
        FROM products p2
        JOIN categories c2
            ON p2.category_id = c2.category_id
        WHERE c2.name = 'Beans'
    );
-- Q3) List subquery (IN with nested lookup):
--     List customers who have purchased at least one product in the 'Merch' category.
--     Return customer_id, first_name, last_name.
--     Hint: Use a subquery to find the category_id for 'Merch', then a subquery to find product_ids.
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM orders o
    WHERE o.order_id IN (
        SELECT oi.order_id
        FROM order_items oi
        WHERE oi.product_id IN (
            SELECT p.product_id
            FROM products p
            WHERE p.category_id IN (
                SELECT cat.category_id
                FROM categories cat
                WHERE cat.name = 'Merch'
            )
        )
    )
);
-- Q4) List subquery (NOT IN / anti-join logic):
--     List products that have never been ordered (their product_id never appears in order_items).
--     Return product_id, name, price.
SELECT
    product_id,
    name,
    price
FROM products
WHERE product_id NOT IN (
    SELECT product_id
    FROM order_items
    WHERE product_id IS NOT NULL
);
-- Q5) Table subquery (derived table + compare to overall average):
--     Build a derived table that computes total_units_sold per product
--     (SUM(order_items.quantity) grouped by product_id).
--     Then return only products whose total_units_sold is greater than the
--     average total_units_sold across all products.
--     Return product_id, product_name, total_units_sold.
SELECT
    ps.product_id,
    p.name AS product_name,
    ps.total_units_sold
FROM (
    SELECT
        product_id,
        SUM(quantity) AS total_units_sold
    FROM order_items
    GROUP BY product_id
) AS ps
JOIN products p
    ON ps.product_id = p.product_id
WHERE ps.total_units_sold > (
    SELECT AVG(total_units_sold)
    FROM (
        SELECT
            product_id,
            SUM(quantity) AS total_units_sold
        FROM order_items
        GROUP BY product_id
    ) AS avg_ps
)
ORDER BY ps.total_units_sold DESC;