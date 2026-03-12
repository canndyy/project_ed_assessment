

SELECT
*
FROM {{ref('stg_patients')}}
where dq_ind = B'1'
