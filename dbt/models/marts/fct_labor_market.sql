{{ config(materialized='table') }}

with labor_with_wages as (
  select
    l.*,
    w.earnings_persons_total,
    w.earnings_males_total,
    w.earnings_females_total
  from {{ ref('stg_labor_force') }} l
  left join {{ ref('stg_wages') }} w 
    on date_trunc('quarter', l.period_date) = w.period_date
),

labor_with_all as (
  select
    lww.*,
    j.vacancies_australia_trend,
    j.vacancies_australia_sa
  from labor_with_wages lww
  left join {{ ref('stg_job_vacancies') }} j 
    on date_trunc('quarter', lww.period_date) = j.period_date
)

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
  earnings_persons_total,
  earnings_males_total,
  earnings_females_total,
  round((earnings_males_total - earnings_females_total) / nullif(earnings_females_total, 0) * 100, 2) as gender_wage_gap_percent,
  vacancies_australia_trend,
  vacancies_australia_sa,
  round(vacancies_australia_trend / nullif(unemployed_persons_trend, 0), 2) as vacancies_per_unemployed_person,
  case
    when vacancies_australia_trend / nullif(unemployed_persons_trend, 0) > 1.0 then 'Severe Skills Shortage'
    when vacancies_australia_trend / nullif(unemployed_persons_trend, 0) > 0.5 then 'Moderate Skills Gap'
    else 'Adequate Labor Supply'
  end as labor_market_condition,
  current_timestamp() as dbt_loaded_at
from labor_with_all
where period_date is not null
order by period_date desc