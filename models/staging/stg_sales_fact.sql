-- models/staging/stg_sales.sql
{{
    config(
        materialized='incremental'
    )
}}

WITH 
{% if is_incremental() %}
-- Calculate the threshold in a separate CTE
latest_threshold AS (
    SELECT MAX(created_at) AS max_ts FROM {{ this }}
),
{% endif %}

source_data AS (
SELECT
    CAST(order_id AS VARCHAR) AS order_id,
    CAST(product_id AS VARCHAR) AS product_id,
    CAST(customer_id AS VARCHAR) AS customer_id,
    CAST(order_date AS DATE) AS order_date,
    order_quantity,
    CAST(order_amount AS DECIMAL(10,2)) AS order_amount,    
    TRIM(payment_method) AS payment_method,
    -- Requirement: Handle NULLs for downstream flag logic
    CAST(COALESCE(discount_applied, 0) AS DECIMAL(10,2)) AS discount_applied,
    CAST(COALESCE(shipping_cost, 0) AS DECIMAL(10,2)) AS shipping_cost,
    CAST(created_at AS TIMESTAMP) AS created_at
FROM {{ ref('sales_fact') }} 
-- Handling edge cases for order_quantity = 0 to ignore the records
WHERE COALESCE(order_quantity,0) > 0

{% if is_incremental() %}
    -- Join with the threshold CTE to filter
    AND created_at > (SELECT max_ts FROM latest_threshold)
{% endif %}
),

deduplicated AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id 
            ORDER BY created_at DESC
        ) as row_num
    FROM source_data
)

SELECT 
    order_id,
    product_id,
    customer_id,
    order_date,
    order_quantity,
    order_amount,
    payment_method,
    discount_applied,
    shipping_cost,
    created_at
FROM deduplicated
WHERE row_num = 1  -- Only keeps the most recent version of the record
