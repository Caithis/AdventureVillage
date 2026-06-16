# Hotfix v0.4.0.1 - Build Mode Input Fix

## Issue

The Build Mode panel appeared, but clicking the buttons did not activate build mode.

Clicking buildings also appeared to do nothing.

## Cause

The full-screen Debug UI root Control was likely intercepting mouse input even while collapsed.

That meant the Build Mode buttons and building click areas underneath could be blocked.

## Fix

- Debug UI root now ignores mouse input.
- Debug UI panel still receives mouse input.
- Build Mode panel has a higher z-index.
- Build Mode panel explicitly stops mouse input.
- Fixed fallback buildings are now labeled `(Fixed Test)` so they are not confused with newly placed buildings.
- Build button presses now print to the console for easier debugging.

## Files Changed

```text
res://scenes/ui/DebugUI.tscn
res://scripts/ui/DebugUI.gd
res://scripts/town/Town.gd
res://scenes/town/Town.tscn
```
