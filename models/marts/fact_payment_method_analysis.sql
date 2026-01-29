-- models/marts/fact_payment_method_analysis.sql
WITH payment_summaries AS (
    SELECT
        payment_method,
        --  Using the macro for total revenue
        ROUND(SUM({{ calculate_revenue('order_amount', 'order_quantity') }}), 2) AS method_revenue,
        -- Total count of orders
        COUNT(order_id) AS total_orders
    FROM {{ ref('stg_sales_fact') }}
    GROUP BY payment_method
),

grand_total AS (
    -- Calculating the total revenue across ALL payment methods for the percentage calculation
    SELECT SUM(method_revenue) AS total_sales_revenue FROM payment_summaries
)

SELECT
    payment_method AS "Payment_method",
    ROUND(method_revenue, 2) AS "Total_revenue",
    total_orders AS "No_Total_Orders",
    -- Average value per order
    ROUND(method_revenue / total_orders, 2) AS "Avg_Order_value",
    -- Percentage of total revenue contributed by this method
    ROUND((method_revenue / (SELECT total_sales_revenue FROM grand_total)) * 100, 2) AS "Distribution_Percentage"
FROM payment_summaries