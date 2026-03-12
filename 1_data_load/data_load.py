import requests
import psycopg
import os

# define function to load source file in csv format

def data_load_csv(source_data_url:str, load_file:str, target_database_url:str, schema:str):

    print(f'Processing {load_file} to {schema}.{load_file.replace(".csv","")} table')
    print(os.path.join(source_data_url, load_file))

    # download data and column headers from source
    response = requests.get(os.path.join(source_data_url, load_file))
    print(f'Connection Status: {response.status_code}')
    data = response.text

    data_split = data.splitlines()
    data_header = data_split[0].split(',')

    # create target table in database of not exists
    columns_sql = ', '.join([f'{col} TEXT' for col in data_header])
    create_sql = f'DROP TABLE IF EXISTS {schema}.{load_file.replace(".csv","")} CASCADE; \
                CREATE TABLE {schema}.{load_file.replace(".csv","")} ({columns_sql});'

    with psycopg.connect(target_database_url) as conn:
        with conn.cursor() as cur:
            cur.execute(create_sql)
        conn.commit()

    # insert source table into target table
    with psycopg.connect(target_database_url) as conn:
        with conn.cursor() as cur:
            with cur.copy(f'COPY {schema}.{load_file.replace(".csv","")} FROM STDIN WITH CSV HEADER;') as copy:
                copy.write(data)


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

    schema = 'raw'

    for csv in source_csv_name:
        data_load_csv(SOURCE_DATA_URL, csv, DATABASE_URL, schema)
