# Future Economy Graphs Notes

## Design Goal

Economy data should eventually be shown visually, not only as raw numbers.

Raw totals are useful for debugging, but players need trend feedback they can act on quickly.

## Useful Graph Types

Potential future graphs:

```text
Gold over time
Daily income vs outflow
Shop sales by day
Inn income by day
Material purchase cost by day
Inventory stock levels over time
Potion stock over time
Slime Gel stock over time
Price trends
Demand trends
Per-building profit trends
Queue/occupancy trends
```

## Why Graphs Matter

Players should be able to answer questions like:

```text
Am I losing money over time?
Is the Inn carrying the town?
Is the General Store draining gold by buying too many materials?
Are upgrades improving throughput?
Are potion stocks trending down?
Are adventurers creating more demand than my workers can handle?
```

## Future Implementation Direction

The Economy sidebar can start with simple text summaries, then add lightweight chart widgets.

Possible steps:
1. Store daily history buckets.
2. Add simple sparkline-style text or ColorRect bars.
3. Add small line graphs for gold/income/outflow.
4. Add item-specific inventory trend graphs.
5. Add per-building profitability graphs.
