# Dungeon Frontier Guild-Town

Version: v0.5.3 - Building Menu Scroll / Compact Mode

## What v0.5.3 Adds

This patch prevents the building detail UI from becoming too tall and hiding controls.

## Scrollable Building Detail Content

The building menu now uses a scrollable content area.

The title and close button stay outside the scrolling section.

This means lower controls such as:

```text
Toggle Slime Gel
Upgrade Building
Worker buttons
```

should remain reachable even when the panel contains many sections.

## Compact Button Layout

Worker controls now use a compact horizontal row:

```text
+ Worker    - Worker
```

The Slime Gel policy button is shortened to:

```text
Toggle Slime Gel (...)
```

## Better Panel Sizing

The building detail panel now behaves more like a right-side sidebar panel:

```text
Fixed right-side position
Taller panel area
Scrollable details
Close button at bottom
```

## Sidebar Direction Documented

This patch also documents the future UI direction:

```text
center gameplay viewport
right-side menu/info sidebar
one major sidebar mode open at a time
future build/debug/economy/info panels living in the sidebar
```

This is inspired by management/strategy layouts where the player can keep the main map readable while using side panels for information and controls.
