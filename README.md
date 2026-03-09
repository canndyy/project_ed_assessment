
## Part A: Data Loading

```
Please see my answers and workbooks in the `1_data_load/` subfolder of this repo.
```

### Load the raw CSV files into a queryable database (e.g. DuckDB, SQLite, Postgres, other) using your preferred approach.

## Part B: Data Assessment
```
Please see my answers and workbooks in the `2_data_assessment/` subfolder of this repo.
```

Now that data has been loaded, please assess these files using your preferred approach, and provide written answers to the following questions:

### B1. Identify at least 3 data quality issues in each of patients.csv and encounters.csv. For each issue:

What is the issue?

Is it blocking (will cause incorrect analytics results) or non-blocking (cosmetic / should be flagged but won't break downstream outputs)?

How would you handle it in your pipeline?

### B2. The file encounters_schema_change_batch.csv has a different schema. How would you unify this with the main encounters data?


## Part C: Transformation Pipeline

```
Please see my answers and workbooks in the `3_data_pipeline` subfolder of this repo.
```

Using your preferred approach, build a pipeline from your loaded raw data to two analyst-ready outputs:

ED Length of Stay — You have been asked to break this down by presenting condition where possible

Frequent Attenders — This should show frequent attenders over 12-month moving time windows
Please provide brief written answers to these questions:

#### C1. If this pipeline ran daily in production and one morning the source data file didn't arrive, how would you detect this? What would happen to the downstream tables?

#### C2. Describe one way you would detect a silent failure — where the pipeline completes successfully but the output data is wrong. Give a concrete example relevant to this dataset.

## Bonus - Extraction of Primary Disorders from ED Clinical Notes
```
Please see my answers and workbook in the `4_data_nlp` subfolder of this repo.
```
data/clinical_notes.csv contains synthetic free-text ED triage notes. Describe (or implement) how you would extract primary disorder as structured information from these notes using an NLP or LLM approach.
