{% test distinct_count_equal(model, column_a, column_b) %}

with counts as (
    select
        count(distinct {{column_a}}) as count_a,
        count(distinct {{column_b}}) as count_b
    from {{ model }}
)

select *
from counts
where count_a != count_b

{% endtest %}
