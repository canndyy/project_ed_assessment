{{config(materialized='table')}}

--description: average LOS of ED encounters by conditions

SELECT
COALESCE(dict.description, 'Not Specified') AS Presenting_Condition,
COUNT(enc.encntr_id) AS Encounter_Count,
CEIL(avg(los_minute)) AS Average_LOS
FROM {{ref('fct_encounters_ed_all')}} enc
LEFT JOIN {{ref('fct_encounter_condition_relation')}} rel
    ON rel.encntr_id=enc.encntr_id
LEFT JOIN {{ref('dim_conditions_all')}} dict
  on rel.con_snomed_cd=dict.sctid
GROUP BY COALESCE(dict.description, 'Not Specified')
ORDER BY CEIL(avg(los_minute)) desc
