-- Defining the Data Dictionary with Header Fields count of Source Files
{% set expected_header_field_counts = {
    'customer': 7,
    'product': 3,
    'product_category': 14,
    'sales_fact': 10
} %}

-- Checking the Tables created from Files Header count against the Data Dictionary
WITH actual_counts AS (
    {% for model_name, expected_count in expected_header_field_counts.items() %}
    SELECT 
        '{{ model_name }}' AS table_name,
        COUNT(column_name) AS actual_field_count,
        {{ expected_count }} AS expected_field_count
    FROM information_schema.columns
    WHERE table_name = '{{ model_name }}'
      AND table_schema = 'main_landing'  
    GROUP BY 1, 3
    
    {% if not loop.last %} UNION ALL {% endif %}
    {% endfor %}
)

SELECT *
FROM actual_counts
WHERE actual_field_count != expected_field_count