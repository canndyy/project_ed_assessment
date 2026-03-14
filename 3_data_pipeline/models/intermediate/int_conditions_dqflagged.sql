{{config(materialized='view')}}

--description: dq flagged records from stg table, not excluded from pipeline

SELECT *
FROM
{{ref('stg_conditions')}}
WHERE dq_ind = B'1'
