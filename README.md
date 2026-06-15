# Dungeon Frontier Guild-Town

Version: v0.3.4 - Slime Nest Growth Pressure

## What v0.3.4 Adds

This patch makes Slime Nest growth more meaningful.

Slime Nest growth now affects:

```text
Nest level
Max active Slimes
Spawn interval
Slime HP
Slime attack
Slime aggro radius
Slime wander radius
Slime movement speed
Slime Gel reward scaling
Raid pressure score
Raid pressure state
```

## Growth Pressure

The Slime Nest now has a calculated pressure state:

```text
Quiet
Watch
High
Raid Risk
```

This is not a real raid system yet. It is the foundation for future raid pressure.

## Slime Scaling

As the nest grows, newly spawned Slimes become stronger.

Examples of scaling:
- Higher nest level increases Slime HP.
- Every few levels can increase Slime attack.
- Slimes can wander and detect adventurers from farther away.
- Spawn interval gets shorter.
- Max active Slime count rises.

## Debug Feedback

The Debug UI now shows more useful Slime Nest pressure information:

```text
Slime Nest status
Growth
Nest level
Raid pressure state
Active Slime count
Spawn interval
Current Slime HP / attack
Raid pressure score
```

## Important Design Note

This patch is not final polish.

It is prototype readability and pressure tuning. The project is still early: the major building systems, placement, resident adventurers, Guild Hall systems, UI, save/load, art, and content progression are not done yet.
