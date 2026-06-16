# Building Costs and Construction Rules

## v0.4.2 Implementation

Building placement now spends village funds.

## Current Costs

```text
Guild Hall: 250g
Inn: 150g
General Store: 175g
```

These values are placeholders.

## Current Refund Rule

```text
Demolish refund = 50% of original cost
```

This gives demolish a cost without being brutally punishing during prototyping.

## Current Rules

```text
New placement:
    costs money

Move placed building:
    free for now

Demolish placed building:
    partial refund

Fixed fallback building:
    protected
```

## Future Construction Direction

Later construction should include:
- build time
- worker/build crew assignment
- material costs
- placement confirmation
- refund tuning
- demolish delay
- build queue
- construction visuals
- save/load for placed buildings
