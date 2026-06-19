# Autosave Slot Foundation

## v0.6.08 Implementation

Autosave is now separate from manual slots.

## Autosave Slot ID

```text
autosave_1
```

## Autosave Files

```text
user://autosave_1_core_state.json
user://autosave_1_building_layout.json
user://autosave_1_economy_history.json
user://autosave_1_adventurer_roster.json
user://autosave_1_world_state.json
```

## Autosave Triggers

Current autosave triggers:

```text
building_placed
building_moved
building_demolished
building_upgraded
new_day_X
```

## Non-Goals For This Patch

Autosave does not yet:
- expose Load Autosave button
- keep multiple autosave rotations
- autosave every economy transaction
- autosave on every simulation tick

Those can be added later if useful.
