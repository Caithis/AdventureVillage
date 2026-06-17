# Dungeon Frontier Guild-Town

Version: v0.5.5 - Sidebar Build Menu Cleanup

## What v0.5.5 Adds

This patch makes the Build Menu feel more native to the sidebar and fixes the debug placeholder wrapping issue.

## Dedicated Sidebar Lane

The project window is widened from the original gameplay width so the right sidebar can live beside the town view instead of covering it.

Current layout direction:

```text
Left / center: 1280-wide gameplay area
Right: sidebar UI lane
```

This is still prototype UI, but it better matches the long-term strategy/management layout direction.

## Build Menu Cleanup

The Build Menu now uses a cleaner sidebar layout:

```text
BUILD MENU
Funds display
Placement instructions
CIVIC
Guild Hall button
SERVICES
Inn button
General Store button
Management controls
```

## Compact Build Buttons

Build buttons are shortened:

```text
Guild Hall - 250g
Inn - 150g
General Store - 175g
```

## Old Collapse Behavior Hidden

The old Build Menu collapse behavior is hidden because sidebar mode buttons now handle switching menus.

## Debug Placeholder Fix

The Debug placeholder text should no longer wrap vertically one letter per line.

Debug still remains a placeholder inside the sidebar. The old Debug overlay still works separately from the top-left Show Debug button.

## Current Limitation

This is not a full sidebar UI manager scene yet.

The sidebar is still built inside `Town.gd`, but it now has a clearer layout direction and a dedicated screen lane.
