import pandas as pd
import os

os.makedirs('data/processed', exist_ok=True)

print("Parsing ABS files with proper headers...\n")

# Labour Force
print("Processing: labour_force_status.xlsx")
df_lf = pd.read_excel('data/raw/labour_force_status.xlsx', 
                       sheet_name='Data1', header=0, skiprows=range(1, 10))
df_lf.to_csv('data/processed/labor_force.csv', index=False)
print(f"✅ labor_force.csv ({len(df_lf)} rows, {len(df_lf.columns)} cols)")

# Wages
print("Processing: avg_weekly_earnings.xlsx")
df_wages = pd.read_excel('data/raw/avg_weekly_earnings.xlsx', 
                          sheet_name='Data1', header=0, skiprows=range(1, 10))
df_wages.to_csv('data/processed/wages.csv', index=False)
print(f"✅ wages.csv ({len(df_wages)} rows, {len(df_wages.columns)} cols)")

# Job Vacancies
print("Processing: job_vacancies.xlsx")
df_vac = pd.read_excel('data/raw/job_vacancies.xlsx', 
                        sheet_name='Data1', header=0, skiprows=range(1, 10))
df_vac.to_csv('data/processed/job_vacancies.csv', index=False)
print(f"✅ job_vacancies.csv ({len(df_vac)} rows, {len(df_vac.columns)} cols)")

print("\n✅ All files parsed with headers!")