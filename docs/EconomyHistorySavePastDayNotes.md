# Economy History Save / Past Day View

## v0.5.9 Implementation

Economy history now saves to JSON.

## Save Path

```text
user://economy_history.json
```

## Saved Fields

```text
version
current_day_number
session_totals
daily_buckets
```

## Daily Bucket Fields

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

## Trend Direction

The sidebar compares current day against previous day:

```text
Net: higher is better
Income: higher is better
Outflow: lower is better
```

Possible trend text:

```text
Up
Down
Flat
```

## Current Limitations

- No chart rendering yet.
- No selectable past-day list yet.
- No rolling average yet.
- No per-building profit history yet.
- Session totals are persisted as part of this prototype, but later save structure may move into a dedicated SaveManager.
