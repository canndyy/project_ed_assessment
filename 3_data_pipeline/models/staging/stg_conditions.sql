{{config(materialized='table', tags=['fresh'])}}

SELECT DISTINCT
  encounter::UUID AS encntr_id,
  patient::UUID AS patient_id,
  start::timestamp AS con_start_dt,
  stop::timestamp AS con_end_dt,
  code::bigint AS con_snomed_cd,
  description AS con_desc,
  CASE
      WHEN start is null then 1
      WHEN start::timestamp >= stop::timestamp THEN 1
      WHEN start::timestamp > current_timestamp THEN 1
      WHEN code is null or description is null THEN 1
      WHEN encounter is null then 1
      ELSE 0
    END::bit AS dq_ind
FROM {{source('raw_data', 'conditions')}}
