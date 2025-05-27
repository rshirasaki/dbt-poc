-- tests/generic/not_null_not_empty.sql
{% test not_null_not_empty(model, column_name) %}

select count(*)
from {{ model }}
where {{ column_name }} is null or trim({{ column_name }}) = ''

{% endtest %}