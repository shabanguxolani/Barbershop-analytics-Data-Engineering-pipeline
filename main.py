from load_bronze import main as load_bronze
from run_sql_scripts import run_sql_script

def main():
    print("Starting Barbershop Analytics ETL Process")

    print("Step 1: Loading Bronze tables")
    load_bronze()

    print("Step 2: Loading Staging Tables")
    run_sql_script("load_staging.sql")

    print("Step 3: Loading Datawarehouse Dimension Tables")
    run_sql_script("load_dw_dims.sql")

    print("Step 4: Loading Datawarehouse Fact Table")
    run_sql_script("load_fact_booking.sql")

    print("ETL Process Completed Successfully")

if __name__ == "__main__":
    main()