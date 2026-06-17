# Sidebar Manager Foundation

## v0.5.4 Implementation

The Town scene now owns a right sidebar container.

## Sidebar Modes

Current modes:

```text
building_details
build_menu
debug_placeholder
```

## Current Sidebar Behavior

Only one sidebar mode is visible at a time.

Mode buttons update the visible panel.

## Embedded Panels

The following are now docked into the sidebar:

```text
BuildingMenu
BuildPanel
```

## Debug Placeholder

Debug is currently a placeholder mode.

The existing Debug UI still works separately. This avoids risking the development tools while the sidebar system is new.

## Future Direction

Later patches should:
- move Build Mode fully into a proper sidebar scene
- move or mirror Debug UI into the sidebar
- add Economy Trends mode
- add Adventurer Overview mode
- add Guild Hall Management mode
- add sidebar close/collapse
- add tabs or category sections
