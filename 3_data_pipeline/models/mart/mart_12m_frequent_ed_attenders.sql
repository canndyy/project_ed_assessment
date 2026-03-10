{{config(materialized='table')}}

with cte as
(
SELECT
patient_id
,COUNT(encntr_id) encounter_count
FROM {{ref('fct_encounters_ed_all')}} fct
WHERE enc_start_dt >= current_timestamp - INTERVAL '12 months'
GROUP BY fct.patient_id
HAVING count(encntr_id) > 3
)

SELECT
fct.patient_id
,pt.first_name
,pt.last_name
,encounter_count
from cte as fct
LEFT JOIN {{ref('dim_patients')}} pt
  on pt.patient_id=fct.patient_id
ORDER BY encounter_count desc
