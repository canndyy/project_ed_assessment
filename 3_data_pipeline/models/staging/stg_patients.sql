{{config(materialized='table', tags=['staging'])}}

-- Select required columns, convert data types and indicate dq rows

SELECT
  id::UUID patient_id,
  birthdate:: date birthdate,
  deathdate:: date deathdate,
  ssn:: VARCHAR(50) ssn,
  first:: VARCHAR(100) first_name,
  last:: VARCHAR(100) last_name,
  address,
  city,
  state,
  county,
  CASE WHEN ssn ~ '^[0-9]{3}-[0-9]{2}-[0-9]{4}$' then 1                       --invalid ssn
    WHEN birthdate:: date > deathdate:: date then 1                           --implausible birth / death dates
    WHEN length(birthdate) > 10 and address = '99 Duplicated Street' THEN 1   --recognised patterns of duplicated rows
    ELSE 0
  END::bit AS dq_ind
from {{source('raw_data','patients')}}
