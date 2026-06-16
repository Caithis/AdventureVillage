# Multi-Building Routing Prototype

## v0.4.8 Implementation

Multiple buildings of the same type now have first-pass routing value.

## Current Selection Rule

For each adventurer:

```text
1. Get all placed buildings of the requested type.
2. If none exist, use fallback.
3. Prefer the nearest building with open capacity.
4. If all are full, choose the building with the lowest pressure score.
```

## Pressure Score

Current pressure score is simple:

```text
(occupants + queue) * large_weight + distance
```

This means queue/capacity pressure matters more than a small distance difference.

## Fallback Rule

Fallback is only used when no placed building of that type exists.

This keeps player-built buildings meaningful.

## Current Route Label

When placed buildings exist, route labels show:

```text
MODE Nearest Open
Mode:Nearest Open | B:<placed_count> | Open:<open>/<capacity> | Q:<queue_count>
```

## Current Limitation

Queue visuals are not yet per building.

The current queue markers follow the watched/last-selected route target. Later, each building should draw its own queue markers.
