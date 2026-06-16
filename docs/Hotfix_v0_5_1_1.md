# Hotfix v0.5.1.1 - Upgrade Type Inference Fix

## Issue

Godot failed to load `Town.gd` with:

```text
Cannot infer the type of "capacity_bonus" variable because the value doesn't have a set type.
```

## Cause

The upgrade capacity calculation used inferred typing with values coming from a Dictionary:

```gdscript
var capacity_bonus := int(UPGRADE_CAPACITY_BONUS_PER_LEVEL.get(building_type, 0)) * max(upgrade_level, 0)
```

`Dictionary.get(...)` returns a loose Variant, so Godot could not safely infer the variable type.

## Fix

Upgrade calculations now use explicit types:

```gdscript
var base_capacity: int
var upgrade_capacity_bonus: int
var capacity_bonus: int
```

The service-speed calculation was also hardened with explicit float types.

## Files Changed

```text
res://scripts/town/Town.gd
```
