# Retreat and Flee Notes

## v0.3.5 Implementation

This version makes retreat more intentional.

## Current Retreat Threshold

```text
HP <= 50%
```

If an outbound traveler reaches this threshold, they stop hunting and flee toward town.

## Flee Status

```text
FleeingToTown
```

This status is used when the adventurer is still alive but is no longer trying to fight.

## Flee Speed

Fleeing or injured travelers use a faster return speed.

This is not final balance. It is a prototype to make retreat readable and survivable.

## Current Safety Rules

Slimes can chase weakened returning travelers, but only under limited conditions:

```text
Traveler must be weakened
Traveler must not be in flee grace period
Traveler must not be near town
Traveler must not have already been chased during this retreat
Only 1 Slime may target one traveler
```

## Why This Matters

Retreat should create tension, not guaranteed failure.

The player should feel:

```text
That adventurer is in trouble.
They need to get home.
A Slime might still catch them.
But they are not doomed automatically.
```

## Future Direction

Later retreat behavior should consider:
- Energy
- Potions
- Distance from town
- Monster speed
- Roads
- Party members
- Adventurer bravery/personality
- Guild Hall safety policies
- Night quest rules
