# Hotfix v0.5.0.1 - BuildingMenu Type Inference Fix

## Issue

Godot failed to launch with:

```text
Cannot infer the type of "can_adjust_workers" variable because the value doesn't have a set type.
```

## Cause

`BuildingMenu.gd` used inferred typing on a boolean expression that included a dynamic method call:

```gdscript
var can_adjust_workers := ...
```

The method call returned a loose `Variant`, so Godot could not infer the variable type safely.

## Fix

The variable is now explicitly typed:

```gdscript
var can_adjust_workers: bool = ...
```

The dynamic method result is also wrapped:

```gdscript
bool(current_town_node.can_adjust_building_workers(current_building_node))
```

## Files Changed

```text
res://scripts/ui/BuildingMenu.gd
```
