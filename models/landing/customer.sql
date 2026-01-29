-- models/staging/customer.sql
{{ config(materialized='table') }}
WITH source AS (
    SELECT * FROM {{ source('raw_data', 'customer') }}
)

-- Copy external file in Bronze layer as it is
SELECT *,
       CURRENT_TIMESTAMP as loaded_at_dbt
FROM source