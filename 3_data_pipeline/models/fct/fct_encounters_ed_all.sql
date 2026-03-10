{{ config(materialized='table') }}

--description: union of current and distinct old EHR records

WITH CTE AS (

SELECT distinct
enc.encntr_id,
enc.patient_id,
enc.enc_start_dt,
enc.enc_end_dt,
EXTRACT(EPOCH FROM (enc_end_dt - enc_start_dt)) / 60 AS los_minute
FROM {{ref('int_encounters_ed')}} enc

UNION

SELECT distinct
enc.encntr_id,
enc.patient_id,
enc.enc_start_dt,
enc.enc_end_dt,
EXTRACT(EPOCH FROM (enc_end_dt - enc_start_dt)) / 60 AS los_minute
FROM {{ref('int_encounters_ed_distinct_schema_change')}} enc

)

SELECT *
,current_timestamp as last_db_run
FROM cte
