# Save Slot Metadata Persistence

## v0.6.5 Implementation

Save slot UI data now persists separately from the actual snapshot files.

## Metadata File

```text
user://save_slots_metadata.json
```

## Metadata Structure

```text
version
active_slot_id
slots
```

Each slot stores:

```text
slot_id
slot_number
label
is_occupied
last_saved_timestamp
last_loaded_timestamp
last_save_result
last_load_result
summary
paths
future_slots_ready
```

## Current Slot

```text
slot_1
```

## Future Direction

The `slots` dictionary can later support:

```text
slot_2
slot_3
autosave_1
quicksave_1
```

## Important Note

This file stores metadata, not full save data.

The actual manual snapshot files remain:

```text
user://slot_1_core_state.json
user://slot_1_building_layout.json
user://slot_1_economy_history.json
user://slot_1_adventurer_roster.json
user://slot_1_world_state.json
```
