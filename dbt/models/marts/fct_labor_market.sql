{{ config(materialized='table') }}

select
  period_date,
  employed_persons_trend,
  employed_persons_sa,
  employed_males_trend,
  employed_females_trend,
  unemployed_persons_trend,
  unemployment_rate_trend,
  labour_force_total_trend,
  participation_rate_trend,
  
  -- Calculated metric (no external joins needed)
  round((employed_males_trend / (employed_males_trend + employed_females_trend)) * 100, 2) as male_employment_pct,
  
  current_timestamp() as dbt_loaded_at

from {{ ref('stg_labor_force') }}

where period_date is not null
order by period_date desc