{{ config(
    materialized='table',
    tags=['metadata'],
    contract={'enforced': false}
) }}

SELECT 
    'GOLD_MARTS' as layer,
    current_timestamp as job_run_at,
    '{{ target.name }}' as run_env,               -- From profiles.yml
    '{{ invocation_id }}' as dbt_run_id           -- Unique ID for this specific execution