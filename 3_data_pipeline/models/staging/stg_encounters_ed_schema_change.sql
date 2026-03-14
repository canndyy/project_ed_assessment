{{config(materialized='table')}}

{% set ed_stay_threshold = '5 days' %}

--description: subset of emergency ED encounters only, with transformed column data types and defined dq cases and

WITH cte as (
SELECT DISTINCT
  id::UUID  AS encntr_id,
  patient::UUID AS patient_id,
  ('1970-01-01 00:00:00'::timestamp + start::bigint / 1000.0 * interval '1 second')::timestamp as enc_start_dt,
  ('1970-01-01 00:00:00'::timestamp + start::bigint / 1000.0 * interval '1 second')::timestamp as enc_end_dt,
  reasoncode::decimal::bigint AS reason_snomed_cd,
  reasondescription AS reason_desc,
  source_system
  FROM {{source('raw_data', 'encounters_schema_change_batch')}}
  WHERE encounter_type = 'emergency'
  )

SELECT *,
CASE
  WHEN enc_start_dt IS NULL THEN 1                  --incomplete encounter
  WHEN enc_end_dt IS NULL THEN 1                    --incomplete encounter
  WHEN enc_start_dt > enc_end_dt THEN 1             --start > stop date
  WHEN enc_start_dt > current_timestamp THEN 1      --future start date
  WHEN enc_end_dt > current_timestamp THEN 1        --future stop date
  WHEN (enc_end_dt - enc_start_dt) > INTERVAL '{{ed_stay_threshold}}' THEN 1  --duration exceed logical threshold
  WHEN encntr_id is null THEN 1                     -- encounter id missing
  ELSE 0
END::bit AS dq_ind
FROM cte
