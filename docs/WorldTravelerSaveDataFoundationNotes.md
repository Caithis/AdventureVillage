# World Traveler Save Data Foundation

## v0.6.3 Implementation

The project now saves a first version of world simulation state.

## Saved World Data

```text
active_world_travelers
returned_traveler_records
visible_slime_state
slime_nest_status
slime_nest_growth
slime_nest_level
raid_pressure_state
next_world_traveler_id
next_world_slime_id
slime_spawn_timer
```

## Vector Handling

World travelers and slimes use `Vector2` positions during gameplay.

For JSON saving, those fields are converted into:

```text
{x, y}
```

On load they are converted back into `Vector2`.

## Current Restore Limits

The save restores dictionaries and world simulation values.

It does not yet perfectly restore:
- exact combat contact timing
- animation state
- future dungeon state
- fog/discovery
- long-term ecology history

## Loaded Town Adventurer Fix

Saved town adventurers now resume a basic town routine after load.

This prevents loaded adventurers from staying in the non-moving `SavedInTown` state.
