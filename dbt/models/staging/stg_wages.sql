{{ config(materialized='view') }}

-- Purpose: Clean wages data
-- Quality checks: 
--   - Exclude Standard Error columns (46% nulls, not needed)
--   - Keep only core earnings metrics
--   - Remove null periods
-- Source: ABS Table 6302.0 (1994-2025)

select
  cast("Unnamed: 0" as date) as period_date,
  
  -- Males earnings (ONLY core earnings, exclude Standard Errors)
  cast("Earnings; Males; Full Time; Adult; Ordinary time earnings ;" as float) as earnings_males_fulltime_ordinary,
  cast("Earnings; Males; Full Time; Adult; Total earnings ;" as float) as earnings_males_fulltime_total,
  cast("Earnings; Males; Total earnings ;" as float) as earnings_males_total,
  
  -- Females earnings (exclude Standard Errors)
  cast("Earnings; Females; Full Time; Adult; Ordinary time earnings ;" as float) as earnings_females_fulltime_ordinary,
  cast("Earnings; Females; Full Time; Adult; Total earnings ;" as float) as earnings_females_fulltime_total,
  cast("Earnings; Females; Total earnings ;" as float) as earnings_females_total,
  
  -- Persons (all) earnings (exclude Standard Errors)
  cast("Earnings; Persons; Full Time; Adult; Ordinary time earnings ;" as float) as earnings_persons_fulltime_ordinary,
  cast("Earnings; Persons; Full Time; Adult; Total earnings ;" as float) as earnings_persons_fulltime_total,
  cast("Earnings; Persons; Total earnings ;" as float) as earnings_persons_total,
  
  -- Metadata
  current_timestamp() as dbt_loaded_at,
  'WAGES' as source_table

from {{ source('raw', 'WAGES') }}

where 
  -- Quality check: Remove null dates
  "Unnamed: 0" is not null
  -- Quality check: Ensure valid date format
  and try_cast("Unnamed: 0" as date) is not null
  -- Quality check: Exclude rows with all earnings nulls
  and (
    "Earnings; Males; Total earnings ;" is not null
    or "Earnings; Females; Total earnings ;" is not null
    or "Earnings; Persons; Total earnings ;" is not null
  )

order by period_date