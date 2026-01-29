{{ config(
    materialized='table',
    tags=['metadata'],
    contract={'enforced': false}
) }}

SELECT 
    'SILVER_STAGING' as layer,
    current_timestamp as job_run_at,
    '{{ target.name }}' as run_env,               -- From profiles.yml
    '{{ invocation_id }}' as dbt_run_id           -- Unique ID for this specific execution