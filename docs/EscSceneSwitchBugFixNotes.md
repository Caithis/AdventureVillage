# ESC Scene Switch Bug Fix Notes

## Issue

If ESC was open and the player switched Town/World views through sidebar buttons, the pause/menu state could become stuck in the previous persistent scene.

This made ESC appear only on the scene where the bug was triggered.

## Fix

Main now closes transient UI before every persistent view switch.

Town and World Map now expose:

```text
force_close_transient_ui()
```

This clears:

```text
ESC overlay visibility
submenu visibility
GameState.simulation_paused
get_tree().paused
```

## Why This Matters

Town and World Map are persistent scenes.

Hidden persistent scenes can still keep UI state unless explicitly reset.
