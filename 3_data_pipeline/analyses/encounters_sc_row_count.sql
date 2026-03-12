select
count(distinct id) cnt_
from raw.encounters_schema_change_batch
union
select count(distinct id) cbt_
from raw.encounters_schema_change_batch encc
where exists (select null from raw.encounters enc where enc.id=encc.id)
