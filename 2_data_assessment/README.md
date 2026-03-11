# Part B: Data Assessment

## B1. Identify at least 3 data quality issues in each of patients.csv and encounters.csv. For each issue:

- What is the issue?
- Is it blocking (will cause incorrect analytics results) or non-blocking (cosmetic / should be flagged but won't break downstream outputs)?
- How would you handle it in your pipeline?

### Data Quality Issues - patients.csv

1. Presence of duplicated patient identifiers, of which some have conflicting demographics data
2. Implausible Birth and Death Dates
2. Patient first and last names in a ilogical format. (non-blocking)

4. Inconsistent ssn format

#### 1. Presence of duplicated patient identifiers, of which some have conflicting demographics data

##### Issue:

- The patient table is expected to hold one set of information per patient, hence the patient identifier (id) is the primary key should be unique and not null.
- When duplicated keys join with other tables, the duplicates can multiply record counts down the pipeline, leading to incorrect agggregated metrics such as averages and counts.
- Conflicting information in duplicated rows can also cause the reporting of inaccurate and incorrect results down the pipeline.

**Blocking to downstream pipeline:** Patient names are required in the pipeline to answer the 2nd question (Which patients are frequent ED attenders?).

##### Approach in pipeline:

1) Drop completely duplicated rows.
2) Investigate conflicting fields in remaining rows with duplicated ids to before deciding data cleaning approach.
  - Mismatch of birthdate and format. (Date vs DateTime)
  - Different numerical suffix added to first, last and maiden names.
  - One of the records among the duplicated ids all have '999 Duplicate Street' as address, this appears to be an incorrect address.
3) Based on the conflicting patterns, clean the data as follow:
    - Remove numerical suffix from column 'first' , 'last' , 'maiden' so duplicated rows now have the same names.
    - For the rest of the records with duplicated patient ids, flag the ones with address '999 Duplicated Street' as DQ and exclude them from downstream analysis.
    - Subset a cleaned table with distinct patient id, first name and last name only.
    - Implement a test to ensure patient ids are unique in the cleaned table.
    - Subset a table with the duplicated ids to investigate for data source issue.

#### 2. Presence of implausible birth dates that are in the future / after death date

##### Issue

- It is logically impossible to have a birth date in the future or after the death date.
- Certain there are incorrect birth / death dates in the table.

**Non-blocking to downstream pipeline**  Birth and Death dates are not required for this analysis pipeline.

#### Approach
1) Flag thse rows as DQ, but can still be included for downstream analysis
2) Subset a table that only contain DQ rows so the data can be fedback to admin staff to correct / investigate.

#### 3. Presence of invalid SSNs.

##### Issue:

- The social security number is a 9-digit number that comes in the format of XXX-XX-XXXX, however some patients' SSN are in an invalid format, using a mixture of letters and special characters.

**Non-blocking to downstream pipeline** Although SSN is also a unique person identifier, patients who are not residents of the country may not have a SSN so this field is an inappropriate patient identifier. id is the primary key and is an unique identifier of each patient, hence SSN is not a required for this analysis pipeline.

##### Approach
1) Flag as DQ to raise awareness but records can still be used in downstream analysis.

#### 4. Low granularity for individual components of birth address

##### Issue

- The BIRTHPLACE column stores the full address in one string.
- Storing the full address in one string can cause difficulty in filtering data, spotting inconsistent data formats.

**Non-blocking to downstream pipeline** birth address is not a required field for this pipeline line.

### Approach

- Not applicable to this pipeline.

### Data Quality Issues - encounters.csv

#### 1. Presence of encounters with a start date after end date

##### Issue:

- Logically impossible to have an encounter starting after it has ended.

**Blocking to downstream analysis** For the first question, calculation of the length of stay (LOS) requires encounter start and end date, this issue will lead to length of stay value of these encounters to become negative, and downstream will lead to incorrect aggregation of the average LOS.

##### Approach:

1) Compare the percentage of such errors among all encounters and the ED subset of encounters before deciding approach to pipeline design.
    - Error rate is about 2%.
    - Similar % from ED compared to total, so not an ED specific problem.
    - The % error is low (~2%), statistically acceptable to flag as DQ and exclude from downstream analysis.
2) Flag these rows as DQ and exclude these records from the downstream pipeline.
3) Create a separate quarantine table with only these DQ rows to be discussed with clinical lead for possible reasons of such errors / compare to frontend EHR if available.

#### 2. Presence of encounters with very long LOS that is clinically implausible

##### Issue:

- Usually it is extremely unlikely for an ED stay to be longer than 3-5 days. Some encounters have LOS of more than > 1 month to a few years, which are clinically implausible.
- It is very likely these data are incorrect

**Blocking to downstream analysis**  Using these records in the pipeline would skew the average LOS (first question).

##### Approach:

1) Flag these rows as DQ.
2) Exclude from downstream analysis.
3) In the pipeline, create a separate quarantine table with only these DQ rows to be discussed with clinical lead for possible reasons of such errors / compare to frontend EHR if available.

#### 3. Presence of encounters with missing reason code / description

##### Issue:

- The clinical reason of the encounter can be found in the reason code and reason description columns, these fields can be used to represent the presenting conditions, but the data is missing for some encounters.

**Blocking to downstream analysis** As the first question requires separating the average LOS by presenting condition, excluding the records with missing data could lead to unrepresentative reporting that only represents patients with recorded reasons.

##### Approach:

1) Investigate the missing rate among all encounters and the ED subset of encounters before deciding on the approach.
  - Missing rate is very high (~70%), data would not be statistically representative of all encounters.
2) Investigate if missing data is random or not random.
3) Analyse other datasets to see if there are information that can also used as to deduce presenting conditions.
  - Eg. Conditions.csv table.
4) As the missing rate is high, excluding records with missing data could lead to bias in reporting, especially if missing data is not random. These encounters should still be included in the pipeline.
5) In encounters where presentating condition information cannot be found, label null reason code/ desc as 'Not Specified', include in downstream analysis.
6) For the first question, include a total count by presenting condition column in addition to the average LOS, this can raise awareness of the data completeness.

#### 4. Some encounter codes can be mapped to multiple different descriptions but of similar meaning.

##### Issue:

- Codes are snomed ct codes. Each SNOMED CT code can have a fully specified name (FSN), and multiple preferred descriptions. The description field contains a mixture of FSNs and preferred descriptions. If left undealt with, any aggregation analysis using the description field will result in multiple categories that actually represent the same concept.

**Non-Blocking to downstream analysis**

EDA reveals that the code and description fields describe the administrative reason of admission rather then presenting conditions (eg. follow up vist). These fields are not required for the analysis pipeline, hence not blocking to downstream analysis.

This problem is not observed in the reason code and description field, however, since data changes over time, it is reasonable to apply a data standardising approach to these fields to ensure pipeline reproducibility.

##### Approach:

For code and description fields:

1) Exclude the code and description columns in the pipeline.

For reason code and reason description fields:

1) Perform aggregation analysis using the reason code only.
2) At the last step of the pipeline, join the reason code to a standard snomed ct dictionary, to ensure only one code is matched to one description.
3) If a standard dictionary table is not available, create a dimension table with 1:1 code-description mapping, using the available reason codes and description in the dataset.

## B2. The file encounters_schema_change_batch.csv has a different schema. How would you unify this with the main encounters data?

1) Investigate difference in schema and data types.

    Difference:
    - column names: column encounterclass changed to encounter_type, but the unique values in both columns are the same
    - data types: both datasets have different timestamp format (one in utc and the other in unix seconds)
    - columns: extra column present to indicate source systems in encounters_schema_change_batch.csv, otherwise all other columns align.

2) Standardise data types.
  Convert start and stop columns to timestamp format. However, it was unknown whether the timestamp was in UTC format or not, this would need to be confirmed with system documentation if available.

3) Standardise column names.
  Convert column name ENCOUNTER_TYPE to ENCOUNTERCLASS, to match with that in encounter.csv

4) Investigate the level of uniqueness of identifiers
  Need to determine if the the source systems share the same identifier system for encounter, patient, origaniztion, payer. (if ids are unique across all systems or only within each system)

  If UUIDs are globally unique across all system, it means that each matching encounter id from the 2 datasets refers to the same encounter. This could be validated by compaing the data fields from the datasets.

  1) The 2 tables can be joined by encounter id.
  2) Merge the datasets to reconcile any missing / incomplete fields.
    Before merging, any inconsistent data would need further investigation.
    Noted the start and stop timestamp are in UTC format but not specified in the schema_change table. The timestamps in the schema_change table is always 1 hour behind that of the encounter table in summer time, which is logically implausible for any time zones.
  3) Records in encounters_schema_change_batch.csv not present in the main encounter table will  be appended (or union joined) to the encounter table.
  4) Keep the column that indicates the source system.

  If UUIDs are only unique in each system, it is not possible to use the uuids only to determine whether the encounters in the schema_change table are the same to that in the encounters table even if the uuids are the same.

  1) Check if a separate master index table is available (more commonly seen for patient / organisation /payer ids, rare for encounters).
  2) If a master encounter index table is available, map each source encounter id to the master encounter id, and perform from step 2 onwards as if the uuids are globally unique. All id columns should also be mapped using their respective master index table.
  3) If master index tables are not available, it is possible to use mapping logic on other encounter data fields to determine if they are duplicates or not. If it is obvious that the fields are identical and the records are duplicates, then proceed to merge, and create a master index table to map the encounters.
  4) If the records are clearly not identical and can be treated as separate encounters, to unify the 2 tables, I would add a suffix to the ids of every encounter referencing the source system(eg. CERN_509c21e2-80e9-4fc7-8279-3137abd0eff6, MAIN_509c21e2-80e9-4fc7-8279-3137abd0eff6, EPIC_509c21e2-80e9-4fc7-8279-3137abd0eff6) to create unique composite keys. The suffix should be in the same format to maintain data consistency.
  5) The same processing logic should apply to other id columns as well.
  3) Lastly I would append (or union join) all the encounters table into one table.
