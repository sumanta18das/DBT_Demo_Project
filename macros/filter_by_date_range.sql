-- macros/filter_by_date_range.sql
{% macro filter_by_date_range(column_name, start_date=None, end_date=None) %}

    {# Validation Logic #}
    {% if start_date and end_date %}
        {% if start_date > end_date %}
            {% do exceptions.raise_compiler_error("Invalid date range: start_date (" ~ start_date ~ ") cannot be after end_date (" ~ end_date ~ ").") %}
        {% endif %}
    {% endif %}

    {# SQL Generation Logic #}
    {% if start_date and end_date %}
        WHERE {{ column_name }} BETWEEN '{{ start_date }}' AND '{{ end_date }}'
    {% elif start_date %}
        WHERE {{ column_name }} >= '{{ start_date }}'
    {% elif end_date %}
        WHERE {{ column_name }} <= '{{ end_date }}'
    {% else %}
        WHERE 1=1
    {% endif %}

{% endmacro %}