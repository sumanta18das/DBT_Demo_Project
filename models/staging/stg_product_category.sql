-- models/staging/stg_product_categories.sql
{{
    config(
        materialized='incremental',
        unique_key='product_id',
        incremental_strategy='merge'
    )
}}

WITH 
{% if is_incremental() %}
-- Calculate the threshold in a separate CTE
latest_threshold AS (
    SELECT MAX(last_updated) AS max_ts FROM {{ this }}
),
{% endif %}

source_data AS (
SELECT 
    -- Cast to VARCHAR to match the 'Schema Contract' in stg_products
    CAST(product_id AS VARCHAR) AS product_id,
    CAST(category_id AS VARCHAR) AS category_id,
    -- Basic cleaning of category names
    TRIM(category_name) AS category_name,
    TRIM(subcategory) AS subcategory,
    TRIM(brand) AS brand,
    CAST(supplier_id AS VARCHAR) AS supplier_id,
    CAST(cost_price AS DECIMAL(10,2)) AS cost_price,
    CAST(retail_price AS DECIMAL(10,2)) AS retail_price,
    CAST(margin_percent AS DECIMAL(10,2)) AS margin_percent,
    CAST(stock_level AS DECIMAL(10,2)) AS stock_level,
    CAST(reorder_point AS DECIMAL(10,2)) AS reorder_point,
    discontinued,
    CAST(launch_date AS DATE) AS launch_date,
    CAST(last_updated AS DATE) AS last_updated

FROM {{ ref('product_category') }} 

{% if is_incremental() %}
    -- Join with the threshold CTE to filter
    WHERE last_updated > (SELECT max_ts FROM latest_threshold)
{% endif %}
),

deduplicated AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY last_updated DESC
        ) as row_num
    FROM source_data
)

SELECT 
     product_id,
     category_id,
     category_name,
     subcategory,
     brand,
     supplier_id,
     cost_price,
     retail_price,
     margin_percent,
     stock_level,
     reorder_point,
    discontinued,
     launch_date,
     last_updated,
FROM deduplicated
WHERE row_num = 1  -- Only keeps the most recent version of the record