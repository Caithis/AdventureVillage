# Dungeon Frontier Guild-Town

Version: v0.3.5 - Adventurer Retreat and Flee Prototype

## What v0.3.5 Adds

This patch improves how weakened world travelers retreat.

## Flee Behavior

Low-HP travelers now actively avoid further Slime targets.

Current retreat rule:

```text
If traveler HP <= 50%:
    Stop hunting Slimes
    Clear Slime target
    Flee directly toward town
```

The traveler status can now show:

```text
FleeingToTown
```

## Faster Return

Fleeing or injured travelers move faster when returning to town.

Current prototype values:

```text
Normal return speed: existing return speed
Flee return speed: 82
```

This helps retreat feel more deliberate and gives weakened adventurers a better chance to survive.

## Stricter Slime Chase Rules

Slimes can still chase weakened retreating adventurers, but the rules are stricter now:

```text
Only weakened returning travelers can be chased
Only 1 Slime may target a traveler
Only 1 retreat chase is allowed per trip
Slimes use a reduced aggro radius against retreating travelers
Travelers get a short grace period after deciding to flee
Slimes stop chasing near the town safety radius
```

This keeps retreat dangerous without making it feel like an automatic death sentence.

## Retreat Feedback

Added clearer floating/status feedback:

```text
Flee!
Fleeing!
Retreat!
Returning
```

## Important Design Note

This is still prototype safety tuning, not final combat polish. The goal is to make the basic loop more fair and readable before adding more content.
