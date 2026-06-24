import os
import pyodbc
from dotenv import load_dotenv

load_dotenv()

SQL_SERVER = os.getenv('SQL_SERVER', r"Tinaxe\development")
SQL_DATABASE = os.getenv('SQL_DATABASE', "BarbershopAnalytics")
SQL_DRIVER = os.getenv('SQL_DRIVER', "ODBC Driver 17 for SQL Server")

def get_connection():
    connection_string = f"DRIVER={SQL_DRIVER};SERVER={SQL_SERVER};DATABASE={SQL_DATABASE};Trusted_Connection=yes;"
    return pyodbc.connect(connection_string)

def split_sql_batches(sql_text):
    batches = []
    current_batch = []

    for line in sql_text.splitlines():
        if line.strip().upper() == 'GO':
            if current_batch:
                batches.append('\n'.join(current_batch))
                current_batch = []

            continue
    if current_batch:
        batches.append('\n'.join(current_batch))

    return batches


def run_sql_script(file_path):
    print(f"Running SQL script: {file_path}")

    with open(file_path, 'r', encoding='utf-8') as file:
        sql_text = file.read()

    batches = split_sql_batches(sql_text)

    with get_connection() as conn:
        cursor = conn.cursor()

        for batch in batches:
            if batch.strip():  # Skip empty batches
                try:
                    cursor.execute(batch)
                    conn.commit()
                    print("Batch executed successfully.")
                except Exception as e:
                    print(f"Error executing batch: {e}")
                    conn.rollback()


if __name__ == "__main__":
    run_sql_script("load_staging.sql")
    run_sql_script("load_dw_dims.sql")
    run_sql_script("load_fact_booking.sql")