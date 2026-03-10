{{config(materialized='view')}}

--description: cleaned staging view to include non-dq records only, distinct to deduplicate

SELECT distinct
  encntr_id,
  patient_id,
  enc_start_dt,
  enc_end_dt,
  reason_snomed_cd
FROM {{ref('stg_encounters_ed')}}
WHERE dq_ind = B'0'
