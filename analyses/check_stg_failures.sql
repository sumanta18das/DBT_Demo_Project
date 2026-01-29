
/* This query gathers total no of failed records from the staging (silver) audit schema.
The 'audit_test_name' column identifies which test failed for that specific row.
*/

select * from main_staging.stg_audit_summary