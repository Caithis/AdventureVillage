# Multi-Monster Outing Notes

## v0.3.3 Implementation

Adventurers can now keep hunting after winning a Slime fight.

## Current Rules

After victory:

```text
If HP <= 50%:
    Return to town with loot.

Else if kills this outing >= 3:
    Return to town with loot.

Else:
    Seek another visible Slime.
```

## Why This Matters

Adventurers should eventually feel like active monster hunters, not delivery workers who touch one enemy and immediately return.

## Current Safety Controls

- HP retreat threshold: 50%.
- Max Slime kills per outing: 3.
- Combat cooldown: 1.5 seconds.
- Max Slimes targeting one traveler: 1.

## Future Tuning

The retreat decision should eventually consider:
- HP
- Energy
- Potion count
- Loot carried
- Adventurer confidence/personality
- Threat level
- Time of day
- Guild Hall policy
- Party size
- Distance from town

## Weakened Retreat Danger

A weakened returning adventurer can be pursued by nearby Slimes.

This creates tension, but the prototype limits it:
- Only one Slime may target the traveler.
- Combat cooldown blocks immediate re-engagement.
- Slimes only chase returning travelers if they are at or below the retreat HP threshold.
