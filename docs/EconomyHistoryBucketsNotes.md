# Economy History Buckets

## v0.5.8 Implementation

Economy tracking now includes a current day bucket.

## Bucket Source

Current day is read from:

```text
GameClock.day_number
```

## Bucket Data

Each bucket stores:

```text
day_number
shop_sales_income
shop_sales_count
inn_income
inn_visit_count
material_purchase_outflow
material_purchase_count
building_construction_outflow
building_construction_count
upgrade_outflow
upgrade_count
```

## Session vs Day

Session totals still track the whole current run.

Day bucket totals track the current in-game day.

## Current Limitation

Buckets are not saved yet.

Future direction:
- save/load economy buckets
- show previous day summaries
- show charts
- show rolling 3-day / 7-day summaries
- show per-building profit
