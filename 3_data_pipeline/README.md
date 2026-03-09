# Part C: Transformation Pipeline

Using your preferred approach, build a pipeline from your loaded raw data to two analyst-ready outputs:

ED Length of Stay — You have been asked to break this down by presenting condition where possible

Frequent Attenders — This should show frequent attenders over 12-month moving time windows

The pipeline is built using dbt in the subfolder `3_data_pipeline`

```
Analyst-ready outputs:
- ED Length of Stay: mart_avg_los_ed_per_pc
- Frequent Attenders: mart_12m_frequent_ed_attenders
```

Please provide brief written answers to these questions:

#### C1. If this pipeline ran daily in production and one morning the source data file didn't arrive, how would you detect this? What would happen to the downstream tables?

To detect if the source data file has not arrived, I would implement a source freshness check pipeline. (In my pipeline the dbt macro `test_source_freshness`.)

After each pipeline run, an audit table would store the maximum activity datetime for each key tables such as encounters, conditions, medications, and observations.

During the next pipeline run, the maximum activity datetime from the newly arrived source file would be compared with the value stored in the audit table. Since new records are expected to contain activity timestamps later than those from the previous run, a failure to observe a newer timestamp would indicate that the source data has not been updated or that the file did not arrive. Automated alerts could then notify data warehouse developers to investigate the issue.

In dbt, `dbt source freshness` can also be used to check data freshness.

If the source file does not arrive, the downstream pipeline should not proceed as it could lead to the compiling of incomplete data in downstream tables.

#### C2. Describe one way you would detect a silent failure — where the pipeline completes successfully but the output data is wrong. Give a concrete example relevant to this dataset.

A silent failure can occur when source tables arrive but they are empty without data.
The pipeline would still run successfully, but the output tables would be empty or incomplete.

To detect this, I would implement pre-process tests to ensure all the source tables contain data (row counts > 0) and all source has fresh data before the pipeline starts. (In my pipeline the dbt macro `test_row_count_not_zero`.)
