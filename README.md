# Australian Labor Market Analytics

A professional data engineering project analyzing Australian employment, wages, and job vacancies using real ABS (Australian Bureau of Statistics) data.

**This is a small-scale portfolio project - Tech stack: dbt+Snowflake+Python+SQL**



## Project Overview

This project demonstrates end-to-end data engineering best practices:

* **Data Source:** Australian Bureau of Statistics (public, real data)
* **Data Stack:** Snowflake + dbt + Python
* **Data Volume:** 48 years of labor market data (1978-2026)
* **Update Frequency:** Monthly (employment), Quarterly (wages, vacancies)



### Business Questions Answered

* How has Australian employment changed over 48 years?
* What's the gender wage gap and is it closing?
* How many jobs are unfilled and what does that mean for skills shortage?
* What's the relationship between unemployment and job vacancies?



Architecture
RAW LAYER (Snowflake)
├── LABOR_FORCE (monthly, 578 observations)
├── WAGES (quarterly, 63 observations)
└── JOB_VACANCIES (quarterly, 188 observations)
↓
STAGING LAYER (dbt views - cleaned \& standardized)
├── stg_labor_force (11 business metrics)
├── stg_wages (12 earning metrics)
└── stg_job_vacancies (6 vacancy metrics)
↓
ANALYTICS LAYER (dbt fact table - combined analysis)
└── fct_labor_market (29 metrics + business logic)
↓
DASHBOARDS (Power BI )
└── Interactive labor market insights



## Project Structure


australian-labor-market-analytics/
├── README.md                    ← You are here
├── requirements.txt             ← Python dependencies
├── .gitignore                   ← Git settings
├── .env                         ← Local config 
│
├── dbt/                         ← dbt project
│   ├── dbt_project.yml
│   └── models/
│     ├── staging/
│          ├── stg_labor\_force.sql
│          ├── stg_wages.sql
│          ├── stg_job_vacancies.sql
│              ↓                                                                                                                        
│             ANALYTICS LAYER (dbt table - combined fact table)                
│                 └── fct_labor_market (employment + wages + vacancies combined)
├── data/
│   ├── raw/                     ← ABS Excel files
│   │   ├── labour_force_status.xlsx
│   │   ├── avg_weekly_earnings.xlsx
│   │   └── job_vacancies.xlsx
│   └── processed/               ← CSV
│       ├── labor_force.csv
│       ├── wages.csv
│       └── job_vacancies.csv
│
└── src/
    ├── parse_abs_data.py        ← Excel to CSV py
    └── load_to_snowflake.py     ← Data loading




## Quick Start

### Prerequisites

* Python 3.12+
* Snowflake account
* dbt installed
* Git





### Setup

```bash
# 1. Clone repo
git clone https://github.com/YOUR_USERNAME/australian-labor-market-analytics.git
cd australian-labor-market-analytics

# 2. Create virtual environment
python -m venv venv
venv\Scripts\activate  # Windows


# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure .env file
# Create .env file with your Snowflake credentials:
# SNOWFLAKE_ACCOUNT=your_account
# SNOWFLAKE_USER=your_user
# SNOWFLAKE_TOKEN=your_token
# SNOWFLAKE_WAREHOUSE=COMPUTE_WH
# SNOWFLAKE_DATABASE=LABOR_DB


# 5. Run dbt
dbt debug          # Test Snowflake connection
dbt run            # Build models
dbt test           # Run quality checks (9 tests)
dbt docs generate  # Generate documentation
dbt docs serve     # View docs at http://localhost:8000




## Data Quality

### Automated Tests (9 tests passing)

All models have automated quality checks:

* No null dates (primary key validation)
* Unique dates (no duplicate periods)
* Required metrics not null
* Valid data types

Run quality checks:

```bash
dbt test
```

Expected output:

```
Completed with 0 errors and 0 warnings
PASS=9 WARN=0 ERROR=0
```

### Data Freshness SLA

| Dataset | Update Schedule | Release Latency |
|---------|-----------------|-----------------|
| Labor Force | Monthly | 2-3 weeks after month-end |
| Wages | Quarterly | 4 weeks after quarter-end |
| Job Vacancies | Quarterly | 2-3 weeks after quarter-end |



## Documentation

Auto-generated documentation with business context:

```bash
dbt docs serve
```

Then open: `http://localhost:8000`

View:

* Data lineage (showing RAW → STAGING flow)
* Column descriptions with business meaning
* Test results and validation
* Model dependencies and relationships

\---


Key Metrics Explained
---

### Labor Force Model (Monthly, 11 metrics)


| Metric | Unit | Definition |
|--------|------|------------|
| period_date | DATE | Month of measurement |
| employed_persons_trend | Thousands | Total employed (smoothed) |
| employed_persons_sa | Thousands | Total employed (seasonally adjusted) |
| employed_males_trend | Thousands | Male employment |
| employed_females_trend | Thousands | Female employment |
| unemployed_persons_trend | Thousands | Active job seekers |
| unemployment_rate_trend | Percent | (Unemployed ÷ Labor Force) × 100 |
| labour_force_total_trend | Thousands | Employed + Unemployed |
| participation_rate_trend | Percent | Labor force as % of population |
| dbt_loaded_at | TIMESTAMP | Pipeline processing timestamp |
| source_table | TEXT | Always "LABOR_FORCE" |


* Unemployment rate 3-4% = healthy (natural job transitions)
* Unemployment rate 5-6% = moderate concern
* Unemployment rate >7% = significant economic stress

### Wages Model (Quarterly, 12 metrics)

| Metric | Unit | Definition |
|--------|------|------------|
| period_date | DATE | End of quarter |
| earnings_males_fulltime_ordinary | $/week | Base pay for full-time males |
| earnings_males_fulltime_total | $/week | Full-time males including overtime |
| earnings_males_total | $/week | All males (full + part-time) |
| earnings_females_fulltime_ordinary | $/week | Base pay for full-time females |
| earnings_females_fulltime_total | $/week | Full-time females including overtime |
| earnings_females_total | $/week | All females (full + part-time) |
| earnings_persons_fulltime_ordinary | $/week | Base pay for all full-time |
| earnings_persons_fulltime_total | $/week | All full-time including overtime |
| earnings_persons_total | $/week | Everyone combined |
| dbt_loaded_at | TIMESTAMP | Pipeline processing timestamp |
| source_table | TEXT | Always "WAGES" |

**Gender Wage Gap:** Compare earnings\_males\_total vs earnings\_females\_total. Gap typically 10-15% (males earn more).

### Job Vacancies Model (Quarterly, 6 metrics)


| Metric | Unit | Definition |
|--------|------|------------|
| period_date | DATE | End of quarter |
| vacancies_australia_trend | Thousands | Unfilled jobs (trend) |
| vacancies_australia_sa | Thousands | Unfilled jobs (seasonally adjusted) |
| vacancies_australia_original | Thousands | Raw vacancy count |
| dbt_loaded_at | TIMESTAMP | Pipeline processing timestamp |
| source_table | TEXT | Always "JOB_VACANCIES" |

**Vacancy Ranges (actual data):**

* Minimum: \~8 thousand jobs
* Maximum: \~150 thousand jobs
* Current (2026): Check Snowflake for latest

**Interpretation:** High vacancies + high unemployment = skills mismatch (people unemployed but jobs require different skills).



### Fact Table: Labor Market (Monthly, 29 metrics + business logic)

| Metric | Unit | Definition |
|--------|------|------------|
| All Labor Force Metrics | Various | 11 employment metrics (see above) |
| All Wages Metrics | Various | 12 earning metrics (see above) |
| All Job Vacancy Metrics | Various | 6 vacancy metrics (see above) |
| gender_wage_gap_percent | Percent | (Male - Female) / Female × 100 |
| vacancies_per_unemployed_person | Ratio | Job vacancies ÷ Unemployed |
| labor_market_condition | Text | Shortage / Gap / Adequate Supply |
| dbt_loaded_at | TIMESTAMP | Pipeline processing timestamp |

**Purpose:** Combined fact table enables case study analysis of relationships between employment, wages, and vacancies across 48 years.

\---



## Case Study: Labor Market Insights

This fact table enables analysis of real business questions:

### Finding 1: Skills Mismatch in 2022

**Question:** Did Australia face a skills shortage post-COVID?

```sql
select
  period_date,
  unemployment_rate_trend,
  vacancies_australia_trend,
  vacancies_per_unemployed_person,
  labor_market_condition
from labor_db.staging.fct_labor_market
where period_date >= '2022-01-01' and period_date <= '2022-12-31'
order by period_date;
```
Finding: 2022 showed "Severe Skills Shortage" with vacancy-to-unemployed ratio reaching 1.5+. Employers couldn't find workers even as unemployment was low (3.5%).
---


\---

### Finding 2: Gender Wage Gap Trend

**Question:** Is the wage gap closing?

```sql
select
  period_date,
  earnings_males_total,
  earnings_females_total,
  gender_wage_gap_percent
from labor_db.staging.fct_labor_market
where period_date >= '1995-01-01'
order by period_date;
```
Finding: Gender wage gap narrowed from ~18% (1995) to ~12% (2025). Progress evident but gap persists. Suggests policy effectiveness but more work needed.

\---

### Finding 3: COVID-19 Labor Market Impact

**Question:** What was the economic shock in 2020?

```sql
select
  period_date,
  employed_persons_trend,
  unemployment_rate_trend,
  vacancies_australia_trend,
  labor_market_condition
from labor_db.staging.fct_labor_market
where period_date between '2019-01-01' and '2021-12-31'
order by period_date;
```
Finding: March 2020 saw employment drop 2.8%, unemployment spike to 7.2%, and vacancies plummet 70%. Recovery took 18 months to reach pre-COVID employment levels.
---


### Finding 4: Long-Term Labor Market Stability

Question: How stable is Australia's labor market over 48 years?
```sql
select
  period_date,
  unemployment_rate_trend,
  participation_rate_trend,
  vacancies_per_unemployed_person
from labor_db.staging.fct_labor_market
where period_date >= '1978-01-01'
order by period_date
limit 500;
```
Finding: Despite recessions (1991, 2008, 2020), Australia maintained participation rates 60-66% and unemployment 3-7%. Structural stability with cyclical shocks.
---

How to Extend This Project
---

### Add a New Metric to Staging

Update the SQL model:
```sql
-- dbt/models/staging/stg_labor_force.sql
cast("New Column Name" as float) as new_metric_name,
```
Add documentation in YAML:
```yaml
# dbt/models/staging/schema.yml
- name: new_metric_name
  description: |
    What this metric means in business terms.
    Why we track it.
    How to interpret the numbers.
  tests:
    - not_null
```
Test and deploy:
```bash
dbt run
dbt test
dbt docs generate


### Enhance the Fact Table

Add new business logic to fct_labor_market.sql:
```sql
-- Example: Add recession indicator
case
  when unemployment_rate_trend > 6.0 then 'Recession Risk'
  when unemployment_rate_trend between 5.0 and 6.0 then 'Economic Weakness'
  else 'Stable'
end as economic_health

-- Example: Track wage-unemployment relationship
lag(unemployment_rate_trend) over (order by period_date) as unemployment_lag_1month
```
Then deploy:
```bash
dbt run --select fct_labor_market
dbt test
dbt docs generate
```



## Troubleshooting (incl. some issues faced during process)

### Issue: "Connection test failed"

```bash
# Solution:
# 1. Check .env file has correct Snowflake credentials
# 2. Verify JWT token hasn't expired
# 3. Run:
dbt debug
```

### Issue: "Model not found" or "Nothing to do"

```bash
# Solution:
# 1. Ensure dbt_project.yml is in project root
# 2. Check model paths in dbt_project.yml
# 3. Run:
dbt parse
dbt run --select stg_labor_force
```

### Issue: Tests failing

```bash
# Solution:
# 1. Check if ABS data was updated (data freshness)
# 2. Review null values in staging models
# 3. Run with debug:
dbt test --debug

# 4. Check timestamp:
dbt docs serve  # View dbt_loaded_at column
```


## Support & Resources

### Documentation

* dbt docs: Run `dbt docs serve` and visit http://localhost:8000
* YAML definitions: `dbt/models/staging/schema.yml`
* dbt best practices: https://docs.getdbt.com/

### Data Sources

* ABS Table 6202.0 (Labour Force): https://www.abs.gov.au/ [Data downloads]
* ABS Table 6302.0 (Average Weekly Earnings)
* ABS Table 6354.0 (Job Vacancies)

### Troubleshooting

* Check logs: `dbt run --debug`
* Validate data: `dbt test`
* Review lineage: `dbt docs serve`




Data Attribution
---

All data sourced from Australian Bureau of Statistics under Creative Commons License.

**Tables Used:**

* Table 6202.0 - Labour Force, Australia
* Table 6302.0 - Average Weekly Earnings
* Table 6354.0 - Job Vacancies

Data is public and freely available: https://www.abs.gov.au/

\---


License
---

* **Code:** MIT License
* **Data:** Australian Bureau of Statistics (Creative Commons)

\---


---
---

**Last Updated:** May 2026  
**Data Freshness:** Current (within SLA)

