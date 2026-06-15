# Future World Monster Spawning

## Long-Term Goal

Monster nests, dungeons, portals, and similar world-map threats should spawn visible enemies around them.

The current system sends travelers directly to the Slime Nest and resolves combat with an invisible Slime. That is acceptable for early prototyping, but not the final direction.

## Future Slime Nest Behavior

A Slime Nest should eventually have:

```text
Nest level
Growth value
Spawn frequency
Max active monsters
Patrol radius
Aggression radius
Night danger modifier
Loot table
Threat/raid pressure
```

Example:

```text
Slime Nest Level 1
Max Slimes: 3
Spawn every 30 seconds
Patrol radius: small
Aggression radius: small
```

As the nest grows:

```text
Higher max monsters
Faster spawn rate
Larger patrol radius
Stronger slimes
Higher raid chance
```

## Visible Monster Behavior

Future monsters should:
- Spawn near the nest.
- Wander within a local area.
- Detect nearby adventurers.
- Move toward adventurers when aggroed.
- Fight when close enough.
- Despawn or return to nest under certain conditions.

## Pathing Considerations

This will eventually require better pathing:
- Simple direct movement first.
- Local wander points.
- Detection radius checks.
- Later, pathfinding around terrain/roads/obstacles.

## Night Modifier Rule

Night modifiers should be temporary.

Correct behavior:
```text
Night starts:
    Monster combat stats are temporarily stronger.

Day starts:
    Temporary night modifier disappears.
```

Incorrect behavior:
```text
Night-spawned monsters permanently keep night strength.
```

The temporary approach keeps night dangerous without permanently ruining daytime balance.
