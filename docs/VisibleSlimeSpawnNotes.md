# Visible Slime Spawn Notes

## v0.3.2 Implementation

The Slime Nest now spawns visible Slime data records in `GameState`.

The World Map visualizes those Slime records as simple green markers.

## Current Slime Data

Each Slime stores:

```text
id
display_name
status
world_position
target_position
home_position
target_traveler_id
is_active
last_event_log
```

## Current Slime Behavior

Slimes can:

```text
Spawn near the Slime Nest
Wander around the nest
Detect nearby outbound travelers
Aggro onto a traveler
Move toward the traveler
Trigger combat when close enough
```

## Anti-Swarm Rule

Current anti-swarm rule:

```text
Only 1 active Slime can target the same traveler.
```

This is intentionally conservative.

Future tuning may include:
- Party size limits
- Threat score
- Adventurer level vs monster level
- Monster personality
- Aggro cooldowns
- Escape rules
- Guild Hall night-quest policy
- Terrain/pathing restrictions

## Current Limitation

Combat is still instant resolution.

Visible Slime markers are the first step. The next step would be:
- Visible combat contact
- Short combat delay or combat bubble
- Damage floating text
- Slime death animation/marker removal
