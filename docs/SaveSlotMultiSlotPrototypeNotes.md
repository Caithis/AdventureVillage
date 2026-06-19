# Save Slot 2 / Slot 3 Prototype

## v0.6.07 Implementation

SaveManager now supports three manual slots:

```text
slot_1
slot_2
slot_3
```

## Active Slot

SaveManager tracks:

```text
active_slot_id
active_slot_number
```

## Dynamic Slot Paths

Snapshot paths are generated from the selected slot id.

Example:

```text
slot_2 + core_state
→ user://slot_2_core_state.json
```

## UI

The Save sidebar now has buttons:

```text
Slot 1
Slot 2
Slot 3
```

## Current Limitations

- No slot rename.
- No save thumbnails.
- No autosave/quicksave slots.
- Confirmations are still sidebar text based, not modal windows.
