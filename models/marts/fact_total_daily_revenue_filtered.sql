-- models/marts/fact_total_daily_revenue_filtered.sql
WITH sales_data AS (
    SELECT 
        order_date,
        -- Using the macro for line item revenue
        {{ calculate_revenue('order_amount', 'order_quantity') }} AS line_item_revenue
    FROM {{ ref('stg_sales_fact') }}
    
    -- Applying the macro here
    {{ filter_by_date_range('order_date', var('start_date', none), var('end_date', none)) }}
),

daily_total AS (
    SELECT
        order_date,
        ROUND(SUM(line_item_revenue),2) AS daily_total_revenue
    FROM sales_data
    GROUP BY order_date
)

SELECT * FROM daily_total

{% if execute and (daily_total | length) == 0 %}
    -- Handling the "no data" case requested
    UNION ALL
    SELECT
        CAST(NULL AS DATE) AS order_date, 
        0.0 AS daily_total_revenue
    WHERE 1=0
{% endif %}