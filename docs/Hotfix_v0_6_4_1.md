# Hotfix v0.6.4.1 - Core State Snapshot Fix

## Issue

Load All did not restore Village Funds or town inventory.

## Cause

Save All did not include a core GameState snapshot.

It saved:
- building layout
- economy history
- active town adventurers
- world state

But not:
- money
- town inventory
- policy toggles

## Fix

Added a manual Slot 1 core state snapshot:

```text
user://slot_1_core_state.json
```

## Also Fixed

Loaded adventurers now avoid blindly resuming the sell-loot path if they have no Slime Gel.
