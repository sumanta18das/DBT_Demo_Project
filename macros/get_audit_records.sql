{% macro get_audit_records(audit_schema) %}

    {% set query %}
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = '{{ audit_schema }}'
    {% endset %}

    {% set results = run_query(query) %}

    {% if execute %}
        {% set table_list = results.columns[0].values() %}
        
        {% if table_list | length > 0 %}
            {% for table in table_list %}
                -- We select the table name and count the rows to standardize the schema
                SELECT 
                    '{{ table }}' AS audit_test_name,
                    COUNT(*) AS failed_record_count
                FROM {{ audit_schema }}.{{ table }}
                -- Having clause ensures we only return tests that actually failed
                HAVING COUNT(*) > 0
                
                {% if not loop.last %} UNION ALL {% endif %}
            {% endfor %}
        {% else %}
            -- Fallback: return an empty standardized schema if no tables exist
            SELECT 
                CAST(NULL AS VARCHAR) AS audit_test_name,
                CAST(0 AS BIGINT) AS failed_record_count
            WHERE 1=0
        {% endif %}
        
    {% else %}
        SELECT CAST(NULL AS VARCHAR) AS audit_test_name, 0 AS failed_record_count WHERE 1=0
    {% endif %}

{% endmacro %}