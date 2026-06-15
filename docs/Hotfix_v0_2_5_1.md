# Hotfix v0.2.5.1 - Returned Traveler Array Crash

## Issue

Godot crashed when a world traveler returned to town.

Error:

```text
_update_world_travelers: Invalid assignment of index '0' (on base: 'Array[Dictionary]') with value of type 'Dictionary'.
```

## Cause

`GameState._update_world_travelers()` was looping through `world_travelers`.

When a traveler reached town, `_mark_traveler_arrived_at_town()` emitted `state_changed` immediately.

The persistent Town scene listened to `state_changed`, claimed the returned traveler, and removed that traveler from `world_travelers` while `GameState._update_world_travelers()` was still inside its loop.

Then `GameState` tried to assign back to an index that had already been removed.

## Fix

Removed the immediate `state_changed.emit()` from `_mark_traveler_arrived_at_town()`.

Now the state change is emitted after the world traveler update loop safely finishes.

## Additional Cleanup

Fixed integer division warnings in `Town.gd` by replacing direct integer division with `floori(float(value) / divisor)`.
