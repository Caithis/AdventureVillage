# Hotfix v0.3.1.1 - FloatingText Type Inference Fix

## Issue

Godot failed to launch because `FloatingText.gd` had a type inference error:

```text
Cannot infer the type of "fade_ratio" variable because the value doesn't have a set type.
```

## Cause

This line did not give Godot enough type information:

```gdscript
var fade_ratio := 1.0 - clamp(age / lifetime, 0.0, 1.0)
```

## Fix

Changed the line to use explicit float typing and `clampf()`:

```gdscript
var fade_ratio: float = 1.0 - clampf(age / lifetime, 0.0, 1.0)
```

## Files Changed

```text
res://scripts/ui/FloatingText.gd
```
