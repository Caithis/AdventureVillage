# Dungeon Frontier Guild-Town

Version: v0.3.2 - Visible Slime Spawn Prototype

## What v0.3.2 Adds

This patch begins replacing invisible Slime Nest combat with visible world-map monsters.

## Visible Slimes

The World Map now displays Slime markers near the Slime Nest.

Slimes:
- Spawn near the Slime Nest.
- Wander around the nest.
- Have visible labels.
- Can be targeted by adventurers.
- Can aggro onto nearby adventurers.

## Slime Nest Spawn Rules

Current prototype rules:

```text
Base max active Slimes: 3
Growth adds more max Slimes
Hard cap: 6 active Slimes
Base spawn interval: 5 seconds
Growth slightly lowers spawn interval
```

This means the Slime Nest begins acting like a living threat source instead of only being a single invisible encounter point.

## Adventurer Targeting

Adventurers now target visible Slimes.

Flow:

```text
Traveler leaves town
→ Traveler looks for active Slime
→ Traveler moves toward visible Slime
→ Combat resolves when close enough
```

If no Slimes are currently active:

```text
Traveler moves to Slime Nest
→ Waits/searches until a visible Slime exists
```

## Mutual Combat / Aggro

Slimes can also detect and approach nearby adventurers.

Current fairness prototype:

```text
Slime aggro radius: 95 px
Max Slimes targeting one traveler: 1
```

That means Slimes can start danger dynamically, but they should not all swarm the same adventurer yet.

## Current Limitation

Combat still resolves instantly when contact happens. Slimes are visible and mobile, but combat is not yet animated or turn-by-turn in the world.
