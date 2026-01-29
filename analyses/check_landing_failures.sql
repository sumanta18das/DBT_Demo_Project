
/* This query gathers total no of failed records from the landing (bronze) audit schema.
The 'audit_test_name' column identifies which test failed for that specific row.
*/

select * from main_landing.landing_audit_summary