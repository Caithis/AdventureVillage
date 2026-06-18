# Economy Trends Sidebar Placeholder

## v0.5.6 Implementation

The sidebar now has an Economy mode.

## Current Display

```text
Current Gold
Income summary placeholders
Outflow summary placeholders
Current stock snapshot
```

## Placeholder Fields

Income:
- Shop sales count
- Inn income
- Loot/material sales impact

Outflow:
- Material purchase cost
- Building construction spend
- Upgrade spend

## Why This Exists Now

The game is becoming a management sim, so the player will eventually need economic feedback:
- where gold comes from
- where gold goes
- what buildings are profitable
- whether services are bottlenecked
- whether material buying is draining funds
- whether upgrades are paying off

## Future Direction

Future economy patches should add actual event logging, such as:

```text
record_shop_sale(amount, item_id)
record_inn_income(amount)
record_material_purchase(amount, item_id)
record_building_purchase(amount, building_type)
record_upgrade_purchase(amount, building_id)
```

Then this sidebar can show real trends instead of placeholders.
