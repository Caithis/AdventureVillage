# Godot Editor Warning Notes

## Observed Warning

```text
scene/gui/text_edit.cpp
Index p_gutter = -1 is out of bounds
```

## Interpretation

This warning comes from Godot's internal TextEdit/gutter system.

It does not point to one of the project's gameplay scripts.

## Current Recommendation

If the game still launches and runs normally, treat this as a low-priority editor warning.

Escalate it only if:
- the project will not launch
- the editor crashes
- the warning repeats constantly during play
- the warning is paired with script errors from `res://scripts/...`
