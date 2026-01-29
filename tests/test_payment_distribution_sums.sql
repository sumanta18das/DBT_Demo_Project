-- This test ensures the sum of payment percentages equals approximately 100%
SELECT
    category_name,
    sales_month,
    (revenue_credit_card_Perc + revenue_paypal_Perc + revenue_debit_card_Perc + revenue_bank_transfer_Perc) as total_perc
FROM {{ ref('fact_monthly_revenue_payment_distribution') }}
-- Allowing for small floating point rounding differences
WHERE ABS(100 - (revenue_credit_card_Perc + revenue_paypal_Perc + revenue_debit_card_Perc + revenue_bank_transfer_Perc)) > 0.1