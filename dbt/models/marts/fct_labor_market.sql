{{ config(materialized='table') }}

select
  l.period_date,
  
  -- EMPLOYMENT METRICS
  l.employed_persons_trend,
  l.employed_persons_sa,
  l.employed_males_trend,
  l.employed_females_trend,
  l.unemployed_persons_trend,
  l.unemployment_rate_trend,
  l.labour_force_total_trend,
  l.participation_rate_trend,
  
  -- WAGE METRICS (quarterly data forward-filled to monthly)
  last_value(w.earnings_persons_total ignore nulls) over (
    order by l.period_date rows between unbounded preceding and current row
  ) as earnings_persons_total,
  
  last_value(w.earnings_males_total ignore nulls) over (
    order by l.period_date rows between unbounded preceding and current row
  ) as earnings_males_total,
  
  last_value(w.earnings_females_total ignore nulls) over (
    order by l.period_date rows between unbounded preceding and current row
  ) as earnings_females_total,
  
  round((last_value(w.earnings_males_total ignore nulls) over (
    order by l.period_date rows between unbounded preceding and current row
  ) - last_value(w.earnings_females_total ignore nulls) over (
    order by l.period_date rows between unbounded preceding and current row
  )) / nullif(last_value(w.earnings_females_total ignore nulls) over (
    order by l.period_date rows between unbounded preceding and current row
  ), 0) * 100, 2) as gender_wage_gap_percent,
  
  -- VACANCY METRICS (quarterly data forward-filled to monthly)
  last_value(j.vacancies_australia_trend ignore nulls) over (
    order by l.period_date rows between unbounded preceding and current row
  ) as vacancies_australia_trend,
  
  last_value(j.vacancies_australia_sa ignore nulls) over (
    order by l.period_date rows between unbounded preceding and current row
  ) as vacancies_australia_sa,
  
  -- BUSINESS LOGIC: SKILLS MISMATCH INDICATOR
  round(last_value(j.vacancies_australia_trend ignore nulls) over (
    order by l.period_date rows between unbounded preceding and current row
  ) / nullif(l.unemployed_persons_trend, 0), 2) as vacancies_per_unemployed_person,
  
  case
    when (last_value(j.vacancies_australia_trend ignore nulls) over (
      order by l.period_date rows between unbounded preceding and current row
    ) / nullif(l.unemployed_persons_trend, 0)) > 1.0 
      then 'Severe Skills Shortage'
    when (last_value(j.vacancies_australia_trend ignore nulls) over (
      order by l.period_date rows between unbounded preceding and current row
    ) / nullif(l.unemployed_persons_trend, 0)) > 0.5 
      then 'Moderate Skills Gap'
    else 'Adequate Labor Supply'
  end as labor_market_condition,
  
  current_timestamp() as dbt_loaded_at

from {{ ref('stg_labor_force') }} l
left join {{ ref('stg_wages') }} w 
  on DATE_TRUNC('quarter', l.period_date) = w.period_date
left join {{ ref('stg_job_vacancies') }} j 
  on DATE_TRUNC('quarter', l.period_date) = j.period_date

where l.period_date is not null
order by l.period_date desc