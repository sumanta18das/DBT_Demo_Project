{% test generic_unique(model, column_name) %}

{{ config(
    severity = 'warn',
    warn_if = '> 10'
) }}

select
    {{ column_name }} as unique_field,
    count(*) as n_records

from {{ model }}
where {{ column_name }} is not null
group by {{ column_name }}
having count(*) > 1

{% endtest %}