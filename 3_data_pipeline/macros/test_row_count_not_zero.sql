{% test row_count_not_zero(model) %}

select count(*)
from {{model}}
having not count(*) > 0

{% endtest %}
