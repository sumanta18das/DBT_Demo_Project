-- models/marts/fact_monthly_revenue_payment_distribution.sql
WITH sales AS (
    SELECT * FROM {{ ref('stg_sales_fact') }}
),
categories AS (
    SELECT * FROM {{ ref('stg_product_category') }}
)
SELECT
    c.category_name,
    strftime(DATE_TRUNC('month', s.order_date), '%B, %Y') AS sales_month,
    
    -- Using the macro for total revenue
    ROUND(SUM({{ calculate_revenue('s.order_amount', 's.order_quantity') }}), 2) AS row_total_revenue,
    
    -- Using the macro within CASE statements for payment percentages
    ROUND((SUM(CASE WHEN s.payment_method = 'credit_card' THEN {{ calculate_revenue('s.order_amount', 's.order_quantity') }} ELSE 0 END) / SUM({{ calculate_revenue('s.order_amount', 's.order_quantity') }}) * 100), 2) AS revenue_credit_card_Perc,
    ROUND((SUM(CASE WHEN s.payment_method = 'paypal' THEN {{ calculate_revenue('s.order_amount', 's.order_quantity') }} ELSE 0 END) / SUM({{ calculate_revenue('s.order_amount', 's.order_quantity') }}) * 100), 2) AS revenue_paypal_Perc,
    ROUND((SUM(CASE WHEN s.payment_method = 'debit_card' THEN {{ calculate_revenue('s.order_amount', 's.order_quantity') }} ELSE 0 END) / SUM({{ calculate_revenue('s.order_amount', 's.order_quantity') }}) * 100), 2) AS revenue_debit_card_Perc,
    ROUND((SUM(CASE WHEN s.payment_method = 'bank_transfer' THEN {{ calculate_revenue('s.order_amount', 's.order_quantity') }} ELSE 0 END) / SUM({{ calculate_revenue('s.order_amount', 's.order_quantity') }}) * 100), 2) AS revenue_bank_transfer_Perc

FROM sales s
JOIN categories c ON s.product_id = c.product_id
GROUP BY c.category_name, DATE_TRUNC('month', s.order_date)
ORDER BY c.category_name ASC, DATE_TRUNC('month', s.order_date) ASC