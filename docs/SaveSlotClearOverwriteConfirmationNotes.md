# Save Slot Clear / Overwrite Confirmation

## v0.6.6 Implementation

This patch makes overwrite and clear-slot controls functional and safer.

## Overwrite Confirmation

Save All checks whether the active slot is occupied.

If it is occupied and overwrite is not armed, Save All is blocked.

## Clear Slot Confirmation

Clear Slot uses a two-step confirmation:

```text
first press: arm clear
second press: delete manual Slot 1 files
```

## Manual Snapshot Files Deleted

```text
user://slot_1_building_layout.json
user://slot_1_core_state.json
user://slot_1_economy_history.json
user://slot_1_adventurer_roster.json
user://slot_1_world_state.json
```

## Files Not Deleted

Live/autosave files are not deleted:

```text
user://placed_buildings.json
user://core_state.json
user://economy_history.json
user://adventurer_roster.json
user://world_state.json
```

## Metadata After Clear

After clearing:
- `is_occupied` becomes false
- summary values become false
- last saved/loaded reset
- save index updates
