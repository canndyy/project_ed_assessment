{{config(materialized='view')}}

SELECT *
FROM
{{ref('stg_conditions')}}
WHERE dq_ind = B'1'
