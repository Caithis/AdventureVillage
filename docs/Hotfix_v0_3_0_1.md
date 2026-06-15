# Hotfix v0.3.0.1 - Debug UI Collapse/Layout Fix

## Issue

The Debug UI collapse button did not shrink the large panel shadow.

The scrollable debug list also failed to appear reliably after the v0.3.0 layout refactor.

## Cause

The collapse button only hid the `ScrollContainer`.

It did not resize the outer `PanelContainer`, so the empty dark panel remained visible.

The `ScrollContainer` also needed a stronger minimum size and fill behavior inside the new VBox layout.

## Fix

- Debug panel now resizes when collapsed.
- Collapsed state now becomes a compact button-only panel.
- Expanded state restores the full debug panel.
- ScrollContainer now has a real minimum height and fill settings.
- Debug list should appear again when expanded.

## Files Changed

```text
res://scenes/ui/DebugUI.tscn
res://scripts/ui/DebugUI.gd
```
