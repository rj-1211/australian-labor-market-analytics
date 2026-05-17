from snowflake.connector import connect
from dotenv import load_dotenv
import os
import pandas as pd
from io import StringIO

load_dotenv()

# Debug: Verify env vars loaded
print(f"Account: {os.getenv('SNOWFLAKE_ACCOUNT')}")
print(f"User: {os.getenv('SNOWFLAKE_USER')}")
print(f"Token present: {bool(os.getenv('SNOWFLAKE_TOKEN'))}")

conn = connect(
    account=os.getenv('SNOWFLAKE_ACCOUNT'),
    user=os.getenv('SNOWFLAKE_USER'),
    token=os.getenv('SNOWFLAKE_TOKEN'),
    warehouse=os.getenv('SNOWFLAKE_WAREHOUSE'),
    database=os.getenv('SNOWFLAKE_DATABASE'),
    schema=os.getenv('SNOWFLAKE_SCHEMA')
)

cursor = conn.cursor()
print("✅ Connected to Snowflake")

# Labour Force
df_lf = pd.read_csv('data/processed/labor_force.csv')
cursor.execute(f"CREATE OR REPLACE TABLE RAW.LABOR_FORCE LIKE (SELECT * FROM (SELECT {', '.join([f'{col}' for col in df_lf.columns])}))") 
cursor.execute(f"INSERT INTO RAW.LABOR_FORCE SELECT * FROM (SELECT * FROM VALUES {', '.join([str(tuple(row)) for row in df_lf.values[:100]])})")
print(f"✅ LABOR_FORCE ({len(df_lf)} rows)")

cursor.close()
conn.close()
print("\n✅ Data loaded!")