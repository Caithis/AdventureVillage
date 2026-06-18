# Economy Event Logging Foundation

## v0.5.7 Implementation

Economy totals are now recorded in `GameState`.

## Income Fields

```text
economy_shop_sales_income
economy_shop_sales_count
economy_inn_income
economy_inn_visit_count
```

## Outflow Fields

```text
economy_material_purchase_outflow
economy_material_purchase_count
economy_building_construction_outflow
economy_building_construction_count
economy_upgrade_outflow
economy_upgrade_count
```

## Event Hooks

Current event hooks:

```text
Adventurer buys Small Potion:
    record_shop_sale_income()

Adventurer rests/sleeps at Inn:
    record_inn_income()

General Store buys Slime Gel:
    record_material_purchase_outflow()

Player places building:
    record_building_construction_outflow()

Player upgrades building:
    record_upgrade_outflow()
```

## Current Limitations

- Session totals only.
- No save/load for economy history yet.
- No daily/weekly history.
- No charts.
- No per-building profit tracking yet.
- Refunds are not tracked separately yet.
- Starting gold is not counted as income.
