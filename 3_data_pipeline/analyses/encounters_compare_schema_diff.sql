select
encc.id
,encc.patient
,enc.start as enc_start
,('1970-01-01 00:00:00'::timestamp + encc.start::bigint / 1000.0 * interval '1 second')::timestamp as encc_start
,enc.stop as enc_stop
,('1970-01-01 00:00:00'::timestamp + encc.stop::bigint / 1000.0 * interval '1 second')::timestamp as encc_stop
,enc.encounterclass
,encc.encounter_type
,enc.organization as enc_org
,encc.organization as encc_org
,enc.provider as enc_provider
,encc.provider as encc_provider
,enc.base_encounter_cost as enc_base
,encc.base_encounter_cost as encc_base
,enc.total_claim_cost as enc_total
,encc.total_claim_cost as encc_total
,enc.payer_coverage as enc_payer_coverage
,encc.payer_coverage as encc_payer_coverage
,enc.base_encounter_cost as enc_base_enc_cost
,encc.base_encounter_cost as encc_base_enc_cost
,enc.total_claim_cost  as enc_total_claim_cist
,encc.total_claim_cost as encc_total_claim_cost
,enc.reasoncode as enc_reason_code
,encc.reasoncode as encc_reason_code
,enc.reasondescription as enc_reasondescription
,encc.reasondescription as encc_reasondescription
,enc.code as enc_code
,encc.code as encc_code
,enc.description as enc_description
,encc.description as encc_description
,encc.source_system
from raw.encounters enc
left join raw.encounters_schema_change_batch encc
on encc.id=enc.id
-- and encc.patient=enc.patient
where encc.id is not null
