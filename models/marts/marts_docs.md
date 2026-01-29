{% docs customer_tier_desc %}
Categorizes customers into three distinct segments based on their lifetime purchase volume:
* **High Value**: Total revenue contribution is greater than or equal to **$1,000**. These are your top-tier clients.
* **Medium Value**: Total revenue contribution is between **$500 and $999.99**.
* **Low Value**: Total revenue contribution is less than **$500**.
The calculation uses the `total_amount` derived from price multiplied by quantity across all historical orders.
{% enddocs %}

{% docs discount_flag_desc %}
An integrity flag used to identify potentially high-risk or outlier transactions.
* **High Discount Flag**: Triggered when the `discount_applied` on an order exceeds **30%** (0.30). 
* **Normal**: All other transactions.
This is used by the finance team to audit margin erosion.
{% enddocs %}

{% docs shipping_flag_desc %}
A logistical efficiency flag.
* **High Shipping Flag**: Triggered if the `shipping_cost` is greater than **10%** of the total `order_amount`. 
* **Normal**: Shipping costs within the standard 10% threshold.
High flags usually indicate small orders with expensive courier routes or international shipping anomalies.
{% enddocs %}

{% docs qoq_growth_desc %}
Calculates the **Quarter-over-Quarter (QoQ)** sales growth percentage for each product category.
* **Formula**: `((Current Quarter Revenue - Previous Quarter Revenue) / Previous Quarter Revenue) * 100`
* **Note**: For the first available quarter in the dataset (where there is no prior quarter to compare), a default value of **999,999** is returned to signify a "New Start" or "Baseline" period.
{% enddocs %}

{% docs sales_volatility_desc %}
Measures the stability of monthly sales using the **Coefficient of Variation (CV)**.
* **Calculation**: `Standard Deviation of Monthly Revenue / Mean Monthly Revenue`
* **Interpretation**: A higher value (e.g., > 1.0) indicates significant seasonality or unpredictable demand, while a lower value indicates stable, predictable revenue streams for that category.
{% enddocs %}