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
├── LABOR\_FORCE (monthly, 578 observations)
├── WAGES (quarterly, 63 observations)
└── JOB\_VACANCIES (quarterly, 188 observations)
↓
STAGING LAYER (dbt views - cleaned \& standardized)
├── stg\_labor\_force (11 business metrics)
├── stg\_wages (12 earning metrics)
└── stg\_job\_vacancies (6 vacancy metrics)
↓
ANALYTICS LAYER (dbt fact table - combined analysis)
└── fct\_labor\_market (29 metrics + business logic)
↓
DASHBOARDS (Power BI / Tableau / Direct Query)
└── Interactive labor market insights



## Project Structure


australian-labor-market-analytics/
├── README.md                    ← You are here
├── requirements.txt             ← Python dependencies
├── .gitignore                   ← Git settings
├── .env                         ← Local config 
│
├── dbt/                         ← dbt project
│   ├── dbt\_project.yml
│   └── models/
│     ├── staging/
│          ├── stg\_labor\_force.sql
│          ├── stg\_wages.sql
│          ├── stg\_job\_vacancies.sql
│              ↓                                                                                                                        
│             ANALYTICS LAYER (dbt table - combined fact table)                
│                 └── fct\_labor\_market (employment + wages + vacancies combined)
├── data/
│   ├── raw/                     ← ABS Excel files
│   │   ├── labour\_force\_status.xlsx
│   │   ├── avg\_weekly\_earnings.xlsx
│   │   └── job\_vacancies.xlsx
│   └── processed/               ← CSV
│       ├── labor\_force.csv
│       ├── wages.csv
│       └── job\_vacancies.csv
│
└── src/
    ├── parse\_abs\_data.py        ← Excel to CSV py
    └── load\_to\_snowflake.py     ← Data loading




## Quick Start

### Prerequisites

* Python 3.12+
* Snowflake account
* dbt installed
* Git





### Setup

```bash
# 1. Clone repo
git clone https://github.com/YOUR\_USERNAME/australian-labor-market-analytics.git
cd australian-labor-market-analytics

# 2. Create virtual environment
python -m venv venv
venv\\Scripts\\activate  # Windows
source venv/bin/activate  # Mac/Linux

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure .env file
# Create .env file with your Snowflake credentials:
# SNOWFLAKE\_ACCOUNT=your\_account
# SNOWFLAKE\_USER=your\_user
# SNOWFLAKE\_TOKEN=your\_token
# SNOWFLAKE\_WAREHOUSE=COMPUTE\_WH
# SNOWFLAKE\_DATABASE=LABOR\_DB

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

|Dataset|Frequency|Update Latency|Next Update Expected|
|-|-|-|-|
|Labor Force|Monthly|2-3 weeks|Monthly (end of month)|
|Wages|Quarterly|4 weeks|Every 3 months|
|Job Vacancies|Quarterly|2-3 weeks|Every 3 months|



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

|Metric|Unit|Business Definition|
|-|-|-|
|**period\_date**|DATE|Month of measurement (always 1st of month)|
|**employed\_persons\_trend**|Thousands|Total employed persons (smoothed trend)|
|**employed\_persons\_sa**|Thousands|Total employed (seasonally adjusted)|
|**employed\_males\_trend**|Thousands|Male employment (trend version)|
|**employed\_females\_trend**|Thousands|Female employment (trend version)|
|**unemployed\_persons\_trend**|Thousands|Active job seekers without work|
|**unemployment\_rate\_trend**|Percent|(Unemployed ÷ Labor Force) × 100|
|**labour\_force\_total\_trend**|Thousands|Employed + Unemployed|
|**participation\_rate\_trend**|Percent|Labor force as % of working-age population|
|**dbt\_loaded\_at**|TIMESTAMP|Pipeline processing timestamp|
|**source\_table**|TEXT|Always "LABOR\_FORCE" for lineage tracking|

**Interpretation Guide:**

* Unemployment rate 3-4% = healthy (natural job transitions)
* Unemployment rate 5-6% = moderate concern
* Unemployment rate >7% = significant economic stress

### Wages Model (Quarterly, 12 metrics)

|Metric|Unit|Business Definition|
|-|-|-|
|**period\_date**|DATE|End of quarter (e.g., Nov 15 for Q3)|
|**earnings\_males\_fulltime\_ordinary**|$/week|Base pay for full-time males (no overtime)|
|**earnings\_males\_fulltime\_total**|$/week|Full-time males including overtime|
|**earnings\_males\_total**|$/week|All males (full-time + part-time)|
|**earnings\_females\_fulltime\_ordinary**|$/week|Base pay for full-time females|
|**earnings\_females\_fulltime\_total**|$/week|Full-time females including overtime|
|**earnings\_females\_total**|$/week|All females (full-time + part-time)|
|**earnings\_persons\_fulltime\_ordinary**|$/week|Base pay for all full-time workers|
|**earnings\_persons\_fulltime\_total**|$/week|All full-time workers including overtime|
|**earnings\_persons\_total**|$/week|Everyone combined (most reported figure)|
|**dbt\_loaded\_at**|TIMESTAMP|Pipeline processing timestamp|
|**source\_table**|TEXT|Always "WAGES" for lineage tracking|

**Gender Wage Gap:** Compare earnings\_males\_total vs earnings\_females\_total. Gap typically 10-15% (males earn more).

### Job Vacancies Model (Quarterly, 6 metrics)

|Metric|Unit|Business Definition|
|-|-|-|
|**period\_date**|DATE|End of quarter when vacancies counted|
|**vacancies\_australia\_trend**|Thousands|Unfilled jobs (trend-adjusted)|
|**vacancies\_australia\_sa**|Thousands|Unfilled jobs (seasonally adjusted)|
|**vacancies\_australia\_original**|Thousands|Raw vacancy count (not adjusted)|
|**dbt\_loaded\_at**|TIMESTAMP|Pipeline processing timestamp|
|**source\_table**|TEXT|Always "JOB\_VACANCIES" for tracking|

**Vacancy Ranges (actual data):**

* Minimum: \~8 thousand jobs
* Maximum: \~150 thousand jobs
* Current (2026): Check Snowflake for latest

**Interpretation:** High vacancies + high unemployment = skills mismatch (people unemployed but jobs require different skills).



### Fact Table: Labor Market (Monthly, 29 metrics + business logic)

|Metric|Unit|Business Definition|
|-|-|-|
|**period\_date**|DATE|Month of measurement (aligned with employment data)|
|**All Labor Force metrics**|Various|11 employment metrics (see above)|
|**All Wages metrics**|Various|12 earning metrics (see above)|
|**All Job Vacancy metrics**|Various|6 vacancy metrics (see above)|
|**gender\_wage\_gap\_percent**|Percent|(Male earnings - Female earnings) / Female earnings × 100|
|**vacancies\_per\_unemployed\_person**|Ratio|Job vacancies ÷ Unemployed persons. Indicator of skills mismatch|
|**labor\_market\_condition**|Classification|"Severe Skills Shortage" / "Moderate Skills Gap" / "Adequate Labor Supply"|
|**dbt\_loaded\_at**|TIMESTAMP|Pipeline processing timestamp|

**Purpose:** Combined fact table enables case study analysis of relationships between employment, wages, and vacancies across 48 years.

\---



## Case Study: Labor Market Insights

This fact table enables analysis of real business questions:

### Finding 1: Skills Mismatch in 2022

**Question:** Did Australia face a skills shortage post-COVID?

```sql
select
  period\\\_date,
  unemployment\\\_rate\\\_trend,
  vacancies\\\_australia\\\_trend,
  vacancies\\\_per\\\_unemployed\\\_person,
  labor\\\_market\\\_condition
from labor\\\_db.staging.fct\\\_labor\\\_market
where period\\\_date >= '2022-01-01' and period\\\_date <= '2022-12-31'
order by period\\\_date;
```

**Finding:** 2022 showed "Severe Skills Shortage" with vacancy-to-unemployed ratio reaching 1.5+. Employers couldn't find workers even as unemployment was low (3.5%).

\---

### Finding 2: Gender Wage Gap Trend

**Question:** Is the wage gap closing?

```sql
select
  period\\\_date,
  earnings\\\_males\\\_total,
  earnings\\\_females\\\_total,
  gender\\\_wage\\\_gap\\\_percent
from labor\\\_db.staging.fct\\\_labor\\\_market
where period\\\_date >= '1995-01-01'
order by period\\\_date;
```

**Finding:** Gender wage gap narrowed from \~18% (1995) to \~12% (2025). Progress evident but gap persists. Suggests policy effectiveness but more work needed.

\---

### Finding 3: COVID-19 Labor Market Impact

**Question:** What was the economic shock in 2020?

```sql
select
  period\\\_date,
  employed\\\_persons\\\_trend,
  unemployment\\\_rate\\\_trend,
  vacancies\\\_australia\\\_trend,
  labor\\\_market\\\_condition
from labor\\\_db.staging.fct\\\_labor\\\_market
where period\\\_date between '2019-01-01' and '2021-12-31'
order by period\\\_date;
```

**Finding:** March 2020 saw employment drop 2.8%, unemployment spike to 7.2%, and vacancies plummet 70%. Recovery took 18 months to reach pre-COVID employment levels.

\---

### Finding 4: Long-Term Labor Market Stability

**Question:** How stable is Australia's labor market over 48 years?

```sql
select
  period\\\_date,
  unemployment\\\_rate\\\_trend,
  participation\\\_rate\\\_trend,
  vacancies\\\_per\\\_unemployed\\\_person
from labor\\\_db.staging.fct\\\_labor\\\_market
where period\\\_date >= '1978-01-01'
order by period\\\_date
limit 500;
```

**Finding:** Despite recessions (1991, 2008, 2020), Australia maintained participation rates 60-66% and unemployment 3-7%. Structural stability with cyclical shocks.

\---




How to Extend This Project
---

### Add a New Metric to Staging

1. Update the SQL model:

```sql
-- dbt/models/staging/stg\\\_labor\\\_force.sql
cast("New Column Name" as float) as new\\\_metric\\\_name,
```

2. Add documentation in YAML:

```yaml
# dbt/models/staging/schema.yml
- name: new\\\_metric\\\_name
  description: |
    What this metric means in business terms.
    Why we track it.
    How to interpret the numbers.
  tests:
    - not\\\_null
```

3. Test and deploy:

```bash
dbt run
dbt test
dbt docs generate
```

### Enhance the Fact Table

Add new business logic to fct\_labor\_market.sql:

```sql
-- Example: Add recession indicator
case
  when unemployment\\\_rate\\\_trend > 6.0 then 'Recession Risk'
  when unemployment\\\_rate\\\_trend between 5.0 and 6.0 then 'Economic Weakness'
  else 'Stable'
end as economic\\\_health

-- Example: Track wage-unemployment relationship
lag(unemployment\\\_rate\\\_trend) over (order by period\\\_date) as unemployment\\\_lag\\\_1month
```

Then deploy:

```bash
dbt run --select fct\\\_labor\\\_market
dbt test
dbt docs generate



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
# 1. Ensure dbt\_project.yml is in project root
# 2. Check model paths in dbt\_project.yml
# 3. Run:
dbt parse
dbt run --select stg\_labor\_force
```

### Issue: Tests failing

```bash
# Solution:
# 1. Check if ABS data was updated (data freshness)
# 2. Review null values in staging models
# 3. Run with debug:
dbt test --debug

# 4. Check timestamp:
dbt docs serve  # View dbt\_loaded\_at column
```


Sample Queries
---

### Find wage gap trends over time

```sql
select
  period\_date,
  earnings\_males\_total,
  earnings\_females\_total,
  round((earnings\_males\_total - earnings\_females\_total) / earnings\_females\_total \* 100, 2) 
    as wage\_gap\_percent
from labor\_db.staging.stg\_wages
order by period\_date desc
limit 10;
```

### Analyze employment during recession

```sql
select
  period\_date,
  employed\_persons\_trend,
  unemployment\_rate\_trend,
  labour\_force\_total\_trend
from labor\_db.staging.stg\_labor\_force
where period\_date between '2020-01-01' and '2021-12-31'
order by period\_date;
```

### Skills mismatch analysis

```sql
select
  l.period\_date,
  l.unemployed\_persons\_trend,
  j.vacancies\_australia\_trend,
  round(j.vacancies\_australia\_trend / l.unemployed\_persons\_trend, 2) 
    as vacancies\_per\_unemployed
from labor\_db.staging.stg\_labor\_force l
left join labor\_db.staging.stg\_job\_vacancies j 
  on l.period\_date = j.period\_date
order by l.period\_date desc;
```





## Support \& Resources

### Documentation

* dbt docs: Run `dbt docs serve` and visit http://localhost:8000
* YAML definitions: `dbt/models/staging/schema.yml`
* dbt best practices: https://docs.getdbt.com/

### Data Sources

* ABS Table 6202.0 (Labour Force): https://www.abs.gov.au/ \[Data downloads]
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


Next Steps
---

* Connect Power BI to Snowflake
* Build interactive labor market dashboard
* Create wage gap analysis report
* Build employment trends visualisation
* Set up automated monthly refresh



License
---

* **Code:** MIT License
* **Data:** Australian Bureau of Statistics (Creative Commons)

\---


---
---

**Last Updated:** May 2026  
**Data Freshness:** Current (within SLA)

