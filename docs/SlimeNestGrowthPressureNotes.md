# Slime Nest Growth Pressure Notes

## v0.3.4 Implementation

The Slime Nest now has stronger scaling hooks.

## Current Growth Effects

Growth affects:

```text
Nest level
Max active Slimes
Spawn interval
Slime HP
Slime attack
Slime Gel reward
Slime wander radius
Slime aggro radius
Slime wander speed
Slime aggro speed
Raid pressure score
Raid pressure state
```

## Nest Level

Current formula:

```text
Nest Level = 1 + floor(growth / 2)
```

This keeps growth readable and avoids every single growth point causing a full jump in monster stats.

## Spawn Pressure

The Slime Nest increases pressure by:
- raising max active Slimes
- reducing spawn interval
- letting Slimes wander farther
- increasing aggro radius

## Combat Pressure

New Slimes use current nest scaling when they spawn.

Scaling examples:
- HP rises with nest level.
- Attack rises more slowly than HP.
- Gel reward rises slowly with nest level.

## Raid Pressure

Raid pressure is currently a score, not an actual raid event.

Current pressure sources:
- Slime Nest growth
- active Slime count
- nest level

Current states:

```text
Quiet
Watch
High
Raid Risk
```

## Future Raid Direction

Future versions should use raid pressure to:
- warn the player
- trigger small monster approach events
- create town-side defense pressure
- give Guild Hall notice opportunities
- encourage clearing or suppressing nests
