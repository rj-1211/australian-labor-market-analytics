{{ config(materialized='view') }}

-- Purpose: Clean job vacancies data
-- Quality checks:
--   - Exclude Standard Error columns (14% nulls, not needed)
--   - Exclude state-level data with nulls (12% missing historical data)
--   - Keep only Australia total (most complete)
--   - Remove null periods
-- Source: ABS Table 6354.0 (1979-2026)

select
  cast("Unnamed: 0" as date) as period_date,
  
  -- Australia total job vacancies (3 variants: Trend, SA, Original)
  -- State-level data excluded due to historical data gaps (nulls in early periods)
  cast("Job Vacancies ;  Australia ;" as float) as vacancies_australia_trend,
  cast("Job Vacancies ;  Australia ;.1" as float) as vacancies_australia_sa,
  cast("Job Vacancies ;  Australia ;.2" as float) as vacancies_australia_original,
  
  -- Metadata
  current_timestamp() as dbt_loaded_at,
  'JOB_VACANCIES' as source_table

from {{ source('raw', 'JOB_VACANCIES') }}

where 
  -- Quality check: Remove null dates
  "Unnamed: 0" is not null
  -- Quality check: Ensure valid date format
  and try_cast("Unnamed: 0" as date) is not null
  -- Quality check: At least one vacancy metric must be non-null
  and (
    "Job Vacancies ;  Australia ;" is not null
    or "Job Vacancies ;  Australia ;.1" is not null
    or "Job Vacancies ;  Australia ;.2" is not null
  )

order by period_date