-- models/staging/stg_customers.sql

{{
    config(
        materialized='incremental',
        unique_key='customer_id',
        incremental_strategy='merge'
    )
}}

WITH 
{% if is_incremental() %}
-- Calculate the threshold in a separate CTE
latest_threshold AS (
    SELECT MAX(loaded_at_dbt) AS max_ts FROM {{ this }}
),
{% endif %}

source_data AS (
    SELECT
    -- Whitespace Trim and Type Casting cleaning
    CAST(customer_id AS VARCHAR) AS customer_id,
    TRIM(customer_name) AS customer_name,
    TRIM(customer_email) AS customer_email,
    CAST(start_date AS DATE) AS start_date,
    CAST(end_date AS DATE) AS end_date,
    status,
    loaded_at_dbt --New field create at Bronze layer for Incremental purpose.
FROM {{ ref('customer') }} 

{% if is_incremental() %}
    -- Join with the threshold CTE to filter
    WHERE loaded_at_dbt > (SELECT max_ts FROM latest_threshold)
{% endif %}
),

deduplicated AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY start_date DESC
        ) as row_num
    FROM source_data
)

SELECT 
    customer_id,
    customer_name,
    customer_email,
    start_date,
    end_date,
    status,
    loaded_at_dbt
FROM deduplicated
WHERE row_num = 1  -- Only keeps the most recent version of the record
