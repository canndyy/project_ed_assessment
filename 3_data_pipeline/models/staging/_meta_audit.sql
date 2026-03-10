{{config(materialized='table')}}

SELECT
'stg_conditions' model
,max(con_start_dt) max_dt_tm
from {{ref('stg_conditions')}}
where dq_ind = B'0'

UNION

SELECT
'stg_encounters_ed' model
,max(enc_start_dt) max_dt_tm
from {{ref('stg_encounters_ed')}}
where dq_ind = B'0'

UNION

SELECT
'stg_encounters_ed_schema_change' model
,max(enc_start_dt) max_dt_tm
from {{ref('stg_encounters_ed_schema_change')}}
