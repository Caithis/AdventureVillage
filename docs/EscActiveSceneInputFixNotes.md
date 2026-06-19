# ESC Active Scene Input Fix Notes

## v0.6.10 Hotfix 2

## Issue

Persistent hidden scenes were still able to receive input.

Because Town and World Map both had `_unhandled_input`, the hidden scene could capture ESC before the visible scene handled it.

## Fix

Main now calls:

```text
set_process_input(false)
set_process_unhandled_input(false)
```

on hidden persistent views.

The active view receives:

```text
set_process_input(true)
set_process_unhandled_input(true)
```

Town and World Map also now have active scene guards:

```text
visible and SceneRouter.current_view_name == expected_view_name
```

## Why This Matters

The project uses persistent Town and World Map scenes.

That is still the right architecture, but input must be routed only to the active visible scene.
