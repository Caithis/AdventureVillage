# Clear Autosave Debug Recovery Notes

## v0.6.10 Hotfix 1

This hotfix adds debug recovery tools for autosave and pause state.

## ClearAuto

Two-step autosave deletion.

Deleted files:

```text
user://autosave_1_building_layout.json
user://autosave_1_core_state.json
user://autosave_1_economy_history.json
user://autosave_1_adventurer_roster.json
user://autosave_1_world_state.json
```

Manual slots are not touched.

## ResetPause

Force-clears transient pause/menu state:

```text
force_close_transient_ui()
GameState.set_simulation_paused(false)
get_tree().paused = false
```

## Why This Exists

During prototype testing, stale save data or stuck pause state can make it hard to tell whether a bug is still present.

These debug tools reduce the need to manually edit JSON files.
