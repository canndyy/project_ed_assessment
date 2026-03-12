{% test date_not_in_future(model, column_name) %}
select *
from {{model}}
where {{column_name}}::timestamp is not null
  and {{column_name}}::timestamp > current_timestamp
{% endtest %}
