{{config(materialized='view', tags=['fresh'])}}

{% set ed_stay_threshold = '5 days' %}

--description: subset of emergency ED encounters only, with transformed column data types and defined dq cases and

SELECT DISTINCT
  id::UUID AS encntr_id,
  patient::UUID AS patient_id,
  start::timestamp AS enc_start_dt,
  stop::timestamp AS enc_end_dt,
  reasoncode::decimal::bigint AS reason_snomed_cd,
  reasondescription AS reason_desc,
  CASE
    WHEN start::timestamp IS NULL THEN 1                --incomplete encounter
    WHEN stop::timestamp IS NULL THEN 1                 --incomplete encounter
    WHEN start::timestamp > stop::timestamp THEN 1      --start > stop date
    WHEN start::timestamp > current_timestamp THEN 1    --future start date
    WHEN stop::timestamp > current_timestamp THEN 1     --future stop date
    WHEN (stop::timestamp - start::timestamp) > INTERVAL '{{ed_stay_threshold}}' THEN 1   --duration exceed threshold
    WHEN id is null THEN 1                              -- encounter id missing
    ELSE 0
  END::bit AS dq_ind
FROM {{source('raw_data', 'encounters')}}
WHERE encounterclass = 'emergency'
