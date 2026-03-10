{{config(materialized='view')}}

--description: extract condition snomed codes from ed encounters
--             only codes with encounter start date after onset date (hence presenting condition at ed)

SELECT distinct
  enc.encntr_id,
  con.con_snomed_cd
FROM {{ref('stg_conditions')}} con
INNER JOIN {{ref('int_encounters_ed')}} enc
  on enc.encntr_id = con.encntr_id
  and enc.enc_start_dt >= con_start_dt

UNION

SELECT distinct
  enc.encntr_id,
  con.con_snomed_cd
FROM {{ref('stg_conditions')}} con
INNER JOIN {{ref('int_encounters_ed_distinct_schema_change')}} enc
  on enc.encntr_id = con.encntr_id
  and enc.enc_start_dt >= con_start_dt
