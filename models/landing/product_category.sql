-- models/staging/product_category.sql
WITH source AS (
    SELECT * FROM {{ source('raw_data', 'product_category') }}
)

-- Copy external file in Bronze layer as it is
SELECT *
FROM source