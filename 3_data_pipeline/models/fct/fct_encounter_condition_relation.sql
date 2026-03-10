{{config(materialized='table')}}

--description: relation table of conditions and encounters (many:many)

WITH CTE AS
(
SELECT distinct
  encntr_id,
  con_snomed_cd
FROM {{ref('int_conditions_from_encounters_ed')}}
WHERE con_snomed_cd is not null

UNION

SELECT distinct
  encntr_id,
  reason_snomed_cd
FROM {{ref('int_encounters_ed')}}
WHERE reason_snomed_cd is not null

UNION

SELECT distinct
  encntr_id,
  reason_snomed_cd
FROM {{ref('int_encounters_ed_distinct_schema_change')}}
WHERE reason_snomed_cd is not null
)

SELECT *
,current_timestamp as last_db_run
FROM cte
