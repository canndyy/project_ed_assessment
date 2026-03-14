import requests
from datetime import datetime
from sqlalchemy import create_engine, Table, MetaData, select, func, desc, inspect
import os
import pandas as pd
from io import StringIO


def data_load_csv(source_data_url:str, load_file:str, target_database_url:str, schema:str):

    """
    Download csv from source_data_url/load_file, then upload to target_database in schema.

    Parameters:
    source_data_url (str): base source url
    load_file (str): file name with file extension (eg. patients.csv)
    target_database_url (str): database connection url
    schema (str): target schema to load to

    Returns: No returns value

    """

    # corresponding table name in dw
    table_dw = load_file.replace(".csv","")

    print(f'Processing {load_file} to {schema}.{table_dw} table')
    print(os.path.join(source_data_url, load_file))

    # download data and column headers from source url
    response = requests.get(os.path.join(source_data_url, load_file))
    print(f'Connection Status: {response.status_code}')
    response.raise_for_status()
    etag = response.headers['ETag']
    csv_data = StringIO(response.text)

    # fetch meta data about file version
    raw_load_meta = {}
    raw_load_meta["load_time"] = datetime.now()
    raw_load_meta["table_name"] = table_dw
    raw_load_meta['etag'] = etag
    raw_load_meta_df = pd.DataFrame.from_dict([raw_load_meta])

    # Connect to sql database
    engine = create_engine(target_database_url)

    # store downloaded data as pandas df
    data = pd.read_csv(csv_data)
    data.columns = [col.lower() for col in data.columns]
    data_columns = data.columns

    # Table existence check
    inspector = inspect(engine)
    table_exists = inspector.has_table(table_dw, schema=schema)

    # Schema validation if table exists
    if table_exists:
        dw_columns = inspector.get_columns(table_dw, schema = schema)
        columns = [col['name'].lower() for col in dw_columns]

        for column in data_columns:
            if column.lower() not in columns:
                raise ValueError(f'Missing column: {column}')

    # Check that version has update
    metadata = MetaData()
    meta_table_name_dw = "_raw_load_meta"
    load_meta = Table(meta_table_name_dw, metadata, autoload_with=engine, schema=schema)

    query = (
        select(load_meta.c.etag)
        .where(load_meta.c.table_name == table_dw)
        .order_by(desc(load_meta.c.load_time))
        .limit(1)
        )

    with engine.connect() as conn:
        result = conn.execute(query)
        dw_max_etag = result.scalar()

    if dw_max_etag != raw_load_meta['etag'] and dw_max_etag != None :
        raise ValueError(f'File has not update.')

    # load tables and update meta
    data.to_sql(table_dw,engine,if_exists='replace', index=False, schema=schema) #replace whole table
    raw_load_meta_df.to_sql("_raw_load_meta",engine,if_exists='append', index=False, schema=schema) #append load record

    print('----Import Completed----')


if __name__ == '__main__':

    DB_USER = os.environ.get('DB_USER')
    DB_PASSWORD = os.environ.get('DB_PASSWORD')
    DB_HOST = os.environ.get('DB_HOST')
    DB_PORT = os.environ.get('DB_PORT')
    DB_TYPE = os.environ.get('DB_TYPE')

    # source and target urls
    SOURCE_DATA_URL = 'https://raw.githubusercontent.com/londonaicentre/datatakehome/refs/heads/main/data'
    DATABASE_URL =f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_TYPE}'

    # source csv names
    source_csv_name = [
                'clinical_notes.csv',
                'conditions.csv',
                'encounters.csv',
                'encounters_schema_change_batch.csv',
                'medications.csv',
                'observations.csv',
                'patients.csv'
                ]

    # target schema
    schema = 'raw'

    for csv in source_csv_name:
        data_load_csv(SOURCE_DATA_URL, csv, DATABASE_URL, schema)
