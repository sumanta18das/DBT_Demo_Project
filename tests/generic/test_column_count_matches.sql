{% test column_count_matches(model, expected_count) %}

-- Checking DBT data Dictionary count against source files count in config
    SELECT 
        COUNT(column_name) AS actual_field_count
    FROM information_schema.columns
    WHERE table_name = '{{ model.identifier }}'
      -- Adjust schema if your models are in a specific schema
      AND table_schema = 'main_landing'
    HAVING COUNT(column_name) != {{ expected_count }}

{% endtest %}