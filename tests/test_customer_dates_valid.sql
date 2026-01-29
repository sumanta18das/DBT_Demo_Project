
/* This test fails if any customer has an end_date that occurs before the start_date.
If this query returns rows, it means the Customer record needs to be checked.
*/

{{ config(
    severity = 'error',
    store_failures = true,
    schema = 'staging_audit'
) }}

SELECT
    customer_id,
    start_date,
    end_date
FROM {{ ref('stg_customer') }}
WHERE end_date < start_date