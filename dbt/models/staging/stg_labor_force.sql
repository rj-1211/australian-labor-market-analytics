{{ config(materialized='view') }}

-- Purpose: Clean labour force data
-- Quality checks: Remove nulls, ensure valid dates, convert types
-- Source: ABS Table 6202.0 (1978-2026)

select
  cast("Unnamed: 0" as date) as period_date,
  
  -- Employment metrics
  cast("Employed total ;  Persons ;" as float) as employed_persons_trend,
  cast("Employed total ;  Persons ;.1" as float) as employed_persons_sa,
  cast("Employed total ;  > Males ;" as float) as employed_males_trend,
  cast("Employed total ;  > Females ;" as float) as employed_females_trend,
  
  -- Unemployment metrics
  cast("Unemployed total ;  Persons ;" as float) as unemployed_persons_trend,
  cast("Unemployment rate ;  Persons ;" as float) as unemployment_rate_trend,
  
  -- Labour force & participation
  cast("Labour force total ;  Persons ;" as float) as labour_force_total_trend,
  cast("Participation rate ;  Persons ;" as float) as participation_rate_trend,
  
  -- Metadata
  current_timestamp() as dbt_loaded_at,
  'LABOR_FORCE' as source_table

from {{ source('raw', 'LABOR_FORCE') }}

where 
  -- Quality check: Remove null dates
  "Unnamed: 0" is not null
  -- Quality check: Ensure valid date format
  and try_cast("Unnamed: 0" as date) is not null

order by period_date