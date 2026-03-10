{{config(materialized='table')}}

---description: dimension table of conditions and descriptions
--              union of condition data of condition and encounter views
--              row_number() and cte used to ensure 1:1 mapping of code to description

with cte as (
select distinct con_snomed_cd, con_desc
from {{ref('stg_conditions')}}
union
select distinct reason_snomed_cd, reason_desc
from {{ref('stg_encounters_ed')}}
union
select distinct reason_snomed_cd, reason_desc
from {{ref('stg_encounters_ed_schema_change')}}
),

cte2 as (
select distinct *
,row_number() over (partition by con_snomed_cd order by length(con_desc) asc) rn
from cte
)

select
con_snomed_cd as sctid,
con_desc description,
current_timestamp as last_db_run
from cte2 where rn = 1
