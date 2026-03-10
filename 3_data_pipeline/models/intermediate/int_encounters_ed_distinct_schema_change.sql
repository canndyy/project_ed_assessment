{{config(materialized='view')}}

--description: cleaned staging view to include non-dq records only that are
--              not in the encounters view, distinct to deduplicate

SELECT distinct
  encntr_id,
  patient_id,
  enc_start_dt,
  enc_end_dt,
  reason_snomed_cd
FROM {{ref('stg_encounters_ed_schema_change')}} s
WHERE dq_ind = B'0'
and NOT EXISTS (
    select null
    from {{ref('int_encounters_ed')}} e
    where e.encntr_id=s.encntr_id)
