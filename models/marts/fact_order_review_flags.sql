-- models/marts/fact_order_review_flags.sql
WITH sales AS (
    SELECT * FROM {{ ref('stg_sales_fact') }}
    -- We only want to see orders that meet at least one risk criteria
    WHERE discount_applied > 0.30 
        OR shipping_cost > (order_amount * 0.10)
)

SELECT
    order_id,
    customer_id,
    product_id,
    order_date,
    order_amount,
    discount_applied,
    shipping_cost,
    -- Flag 1: Discount > 30% (represented as 0.30 in the data)
    CASE 
        WHEN discount_applied > 0.30 THEN 'High Discount Flag' 
        ELSE 'Normal' 
    END AS discount_flag,
    -- Flag 2: Shipping > 10% of order_amount
    CASE 
        WHEN shipping_cost > (order_amount * 0.10) THEN 'High Shipping Flag' 
        ELSE 'Normal' 
    END AS shipping_flag
FROM sales
ORDER BY order_id