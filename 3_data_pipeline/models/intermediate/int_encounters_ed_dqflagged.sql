{{ config(materialized='view') }}

SELECT *
FROM {{ref('stg_encounters_ed')}}
WHERE dq_ind = B'1'
