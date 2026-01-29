-- models/marts/fact_seasonal_sales_analysis.sql

WITH monthly_revenue_base AS (
    SELECT
        c.category_name,
        DATE_TRUNC('month', s.order_date) AS sales_month_date,
        DATE_TRUNC('quarter', s.order_date) AS sales_quarter_date,
        -- Using the macro for total revenue
        ROUND(SUM({{ calculate_revenue('s.order_amount', 's.order_quantity') }}), 2) AS monthly_revenue
    FROM {{ ref('stg_sales_fact') }} s
    JOIN {{ ref('stg_product_category') }} c ON s.product_id = c.product_id
    GROUP BY c.category_name, DATE_TRUNC('month', s.order_date), DATE_TRUNC('quarter', s.order_date)
),

quarterly_growth_calc AS (
    SELECT
        category_name,
        sales_quarter_date,
        SUM(monthly_revenue) AS quarterly_revenue,
        LAG(SUM(monthly_revenue)) OVER (PARTITION BY category_name ORDER BY sales_quarter_date) AS prev_quarter_revenue
    FROM monthly_revenue_base
    GROUP BY category_name, sales_quarter_date
),

category_statistics AS (
    SELECT
        category_name,
        AVG(monthly_revenue) AS avg_monthly_rev,
        STDDEV(monthly_revenue) AS stddev_monthly_rev,
        MAX(monthly_revenue) AS max_rev,
        MIN(monthly_revenue) AS min_rev
    FROM monthly_revenue_base
    GROUP BY category_name
)

SELECT
    m.category_name,
    strftime(m.sales_month_date, '%B, %Y') AS "Month",
    -- FIX: Wrap multi-word aliases in double quotes
    m.monthly_revenue AS "Monthly_Sales",
    -- Quarter-over-Quarter Growth Rate
    COALESCE(
        ROUND(((q.quarterly_revenue - q.prev_quarter_revenue) / NULLIF(q.prev_quarter_revenue, 0)) * 100, 2), 
        999999
    )  AS "QoQ_Growth_Percentage",
    -- Identify Best/Worst Months
    (CASE 
        WHEN m.monthly_revenue = s.max_rev THEN 'Best Performing Month'
        WHEN m.monthly_revenue = s.min_rev THEN 'Worst Performing Month'
        ELSE 'Normal'
    END) AS "Monthly_Performance_Status",
    -- Coefficient of Variation (Volatility)
    ROUND(s.stddev_monthly_rev / NULLIF(s.avg_monthly_rev, 0), 2)  AS "Sales_Volatility"
FROM monthly_revenue_base m
JOIN quarterly_growth_calc q 
    ON m.category_name = q.category_name 
    AND m.sales_quarter_date = q.sales_quarter_date
JOIN category_statistics s 
    ON m.category_name = s.category_name
ORDER BY m.category_name, m.sales_month_date