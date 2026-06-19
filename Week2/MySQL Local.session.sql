WITH daily_revenue AS (
    SELECT
        o.store_id,
        DATE(o.order_datetime) AS order_date,
        SUM(oi.quantity * p.price) AS revenue_day
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        o.store_id,
        DATE(o.order_datetime)
)

SELECT
    s.store_name,
    dr.order_date,
    dr.revenue_day,
    AVG(dr.revenue_day) OVER (
        PARTITION BY dr.store_id
        ORDER BY dr.order_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3day_avg
FROM daily_revenue dr
JOIN stores s
    ON dr.store_id = s.store_id
ORDER BY
    s.store_name,
    dr.order_date;