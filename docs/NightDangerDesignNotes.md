# Night Danger Design Notes

## v0.2.9 Implementation

Night now affects world-map risk.

## Current Night Combat Modifier

```text
Slime HP: 1.5x at Night
Slime Attack: 1.5x at Night
```

This is temporary and calculated only when combat resolves.

## Current Night Travel Rules

If a traveler is outbound to the Slime Nest at Night:

```text
If Night Quests are disabled:
    Return to town.

Else if traveler energy <= 40:
    Return to town.

Else:
    Continue as NightQuesting.
```

## Future Guild Hall Direction

The debug Night Quest toggle should eventually become a Guild Hall policy.

Possible future Guild Hall options:

```text
Allow Night Quests: On/Off
Only allow prepared adventurers at Night
Minimum HP for Night Quests
Minimum Energy for Night Quests
Require Torch/Supply item
Emergency recall at Night
```

## Future Night Danger Direction

Night may later affect:
- Monster patrol radius
- Encounter chance
- Monster aggression
- Adventurer vision range
- Torch/supply demand
- Raid pressure on town
- Retreat decisions
