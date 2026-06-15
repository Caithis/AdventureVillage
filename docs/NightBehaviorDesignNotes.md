# Night Behavior Design Notes

## v0.2.7 Implementation

This version introduces basic Night behavior for free/preparing town adventurers.

## Current Rules

### Normal Rest

Outside of night sleep, adventurers prefer the Inn only if:

```text
HP <= 50%
Energy <= 40%
```

### Night Sleep

If it is Night and the adventurer is free/preparing, they seek the Inn even if HP and energy are acceptable.

### Quest Continuation

Adventurers already committed to world travel / quest flow continue for now.

## Why This Split Matters

The Inn should not be overused during the day. Adventurers should keep adventuring if they are still healthy and energetic enough.

At night, the Inn serves a different purpose: sleep and safety.

## Future Tuning

These thresholds should be playtested:
- HP 50% may be too safe or too risky.
- Energy 40% may need to become 30%, 50%, or depend on adventurer personality/class.
- Night sleep may eventually depend on room availability and adventurer wealth.

## Future Danger Scaling

Night can later affect:
- Monster activity
- Encounter chance
- Adventurer retreat decisions
- Torch/supply needs
- Guild notice urgency
- Town raid chance
