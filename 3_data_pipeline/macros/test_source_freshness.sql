{% test source_freshness(model, source_max_dt) %}

with meta as (
    select max_dt_tm as meta_max_dt
    from {{ref('_meta_audit')}}
    where model = '{{model.name}}'
),
source as (
    select max({{source_max_dt}}) as source_max_dt
    from {{model}}
)
select *
from meta
cross join source
where source_max_dt <= meta_max_dt

{% endtest %}
