# Dungeon Frontier Guild-Town

Version: v0.3.0 - Basic Building Economy Controls

## What v0.3.0 Adds

This patch starts the foundation for building-level economy controls.

## General Store Material Buying

The General Store now has a buying policy for Slime Gel:

```text
Buy Slime Gel: Enabled / Disabled
```

If enabled:

```text
Returned adventurer can sell Slime Gel.
Village funds decrease.
Town Slime Gel stock increases.
Adventurer gold increases.
```

If disabled:

```text
Returned adventurer cannot sell Slime Gel.
Adventurer keeps their Slime Gel.
Village funds do not decrease.
Adventurer label shows that the store is not buying Slime Gel.
```

## Building Interaction

The General Store can now be clicked.

When clicked:

```text
General Store menu opens.
Menu shows whether Slime Gel buying is enabled.
Menu has a toggle button for buying Slime Gel.
```

The General Store also highlights when the cursor hovers over it.

This is a prototype interaction system. Later, this should expand into a real building menu system for all buildings.

## Debug UI Improvement

The Debug UI is now collapsible.

```text
Hide Debug
Show Debug
```

The scrollable debug controls remain available, but the panel can now be minimized so you can watch the simulation more clearly.

## Future Direction

This is the beginning of:
- Building click menus
- Hover highlights
- Material buy toggles
- Material stock controls
- Building budget controls
- Future sliders for buying limits

## Hotfix v0.3.0.1 Notice

This package fixes the Debug UI collapse/layout bug.

Fixed:
- Hide Debug now shrinks the panel instead of leaving the large empty shadow box.
- Show Debug restores the full debug list.
- ScrollContainer has a stable height so the list displays properly.
