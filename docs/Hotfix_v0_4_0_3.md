# Hotfix v0.4.0.3 - Missing UI Helper Fix

## Issue

Godot failed to launch with:

```text
Function "_is_mouse_over_ui()" not found in base self.
```

## Cause

v0.4.0.2 added a call to `_is_mouse_over_ui(mouse_position)` inside `Town.gd`, but the helper function did not make it into the file correctly.

## Fix

Added the missing helper functions:

```gdscript
func _is_mouse_over_ui(mouse_position: Vector2) -> bool
func _control_contains_global_point(control: Control, point: Vector2) -> bool
```

## Files Changed

```text
res://scripts/town/Town.gd
```
