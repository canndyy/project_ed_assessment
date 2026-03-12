{% test start_before_end(model, column_start, column_end) %}
select *
from {{model}}
where {{column_end}}::timestamp is not null
  and {{column_start}}::timestamp >= {{column_end}}::timestamp
{% endtest %}
