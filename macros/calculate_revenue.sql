-- macros/calculate_revenue.sql
{% macro calculate_revenue(amount_column, quantity_column) %}
    ({{ amount_column }} * {{ quantity_column }})
{% endmacro %}