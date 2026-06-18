# Hotfix v0.6.1.1 - Manual Save Snapshot Fix

## Issue

Save All was not restoring the expected earlier state because placement/demolition auto-save was overwriting the same file Load All used.

## Cause

Save All and the building live-save system both used:

```text
user://placed_buildings.json
```

Economy history had a similar issue with:

```text
user://economy_history.json
```

## Fix

Save All / Load All now use separate manual Slot 1 snapshot files:

```text
user://slot_1_building_layout.json
user://slot_1_economy_history.json
```

The old live files still exist and can continue supporting individual/auto-save behavior.

## Files Changed

```text
res://scripts/autoload/SaveManager.gd
res://scripts/town/Town.gd
```
