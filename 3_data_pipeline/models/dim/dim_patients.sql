{{config(materialized='table')}}

with cte as (
SELECT DISTINCT
  patient_id,
  REGEXP_REPLACE(first_name, '[0-9]+', '', 'g') AS first_name,
  REGEXP_REPLACE(last_name, '[0-9]+', '', 'g') AS last_name,
  row_number() over (partition by patient_id) rn --if update_dt available would order by that
from {{ref('stg_patients')}}
)

select
patient_id,
first_name,
last_name,
current_timestamp as last_db_run
from cte
where rn = 1
