{{ config(materialized='view') }}

--description: dq flagged records from stg table, excluded from pipeline

SELECT *
FROM {{ref('stg_encounters_ed')}}
WHERE dq_ind = B'1'
