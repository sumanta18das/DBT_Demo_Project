{{ config(
    materialized='view',
    contract={'enforced': false}
) }}
-- Creating View to see Test Fail Records
{{ get_audit_records('main_staging_audit') }}