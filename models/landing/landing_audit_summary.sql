{{ config(materialized='view') }}
-- Creating View to see Test Fail Records
{{ get_audit_records('main_landing_audit') }}