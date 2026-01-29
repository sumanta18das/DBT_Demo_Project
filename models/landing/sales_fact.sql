-- models/staging/sales_fact.sql
-- As it is Large file so creating as a table
{{ config(materialized='table')}} 

WITH source AS (
    SELECT * FROM {{ source('raw_data', 'sales_fact') }}
)

-- Copy external file in Bronze layer as it is
SELECT *
FROM source