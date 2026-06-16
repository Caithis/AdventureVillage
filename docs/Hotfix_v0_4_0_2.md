# Hotfix v0.4.0.2 - Build Placement Click and Hover Stability

## Issue

Build Mode buttons worked, but:
- Hover outline/glow on buildings flickered.
- Left-click did not place the building ghost.
- Right-click did not cancel build mode.
- Cancel button still worked.

## Likely Causes

### Hover flicker

The building child controls, such as labels and highlight rectangles, could interfere with parent building hover detection.

### Placement click failure

Build placement used `_unhandled_input()`. With several UI Controls now layered in the scene, `_unhandled_input()` was not reliable enough for placement/cancel clicks.

## Fix

- Building labels and hover highlight now ignore mouse input.
- Building parent ColorRect owns hover/click input.
- Build placement now uses `_input()` instead of `_unhandled_input()`.
- Build placement ignores clicks over the Build Mode panel and building menu.
- Left-click placement and right-click cancel now print debug messages.
- Build buttons use no focus mode to avoid extra UI focus weirdness.

## Files Changed

```text
res://scripts/buildings/ClickableBuilding.gd
res://scripts/town/Town.gd
```
