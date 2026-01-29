-- models/marts/fact_customer_tiering.sql
WITH customer_sales AS (
    SELECT
        customer_id,
        -- Total number of unique orders placed
        COUNT(order_id) AS total_orders,
        -- Using the macro for total revenue
        ROUND(SUM({{ calculate_revenue('order_amount', 'order_quantity') }}), 2) AS total_amount
    FROM {{ ref('stg_sales_fact') }}
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.customer_name,
    -- Customer Tiering Logic based on Total Amount
    CASE 
        WHEN cs.total_amount >= 1000 THEN 'High Value'
        WHEN cs.total_amount >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS "Customer_Tier",
    COALESCE(cs.total_amount, 0) AS "Total_Purchase_Amount",
    COALESCE(cs.total_orders, 0) AS "Total_No_Orders"
FROM {{ ref('stg_customer') }} c
LEFT JOIN customer_sales cs ON c.customer_id = cs.customer_id
ORDER BY c.customer_id