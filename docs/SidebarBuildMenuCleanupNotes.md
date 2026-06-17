# Sidebar Build Menu Cleanup

## v0.5.5 Implementation

The Build Menu is now formatted for the sidebar.

## Layout

```text
BUILD MENU
Funds
Placement instructions

CIVIC
Guild Hall

SERVICES
Inn
General Store

MANAGEMENT
Move
Demolish
Save
Load
Cancel
```

## Why the Old Collapse Button Is Hidden

The old collapse button was useful when the Build Menu was a floating panel.

Now the sidebar mode buttons handle panel switching, so collapse behavior is redundant.

## Current Limitation

The Build Menu is still dynamically generated in `Town.gd`.

Eventually it should become its own scene/script:

```text
BuildMenuPanel.tscn
BuildMenuPanel.gd
```
