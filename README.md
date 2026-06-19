# Dungeon Frontier Guild-Town

Version: v0.6.10 Hotfix 2 - Active Scene ESC Input Fix

## What This Fixes

This hotfix fixes the issue where ESC paused the Town scene but the ESC menu did not appear in Town.

## Root Cause

Town and World Map are persistent scenes.

Even when one scene was hidden, its input handler could still receive ESC.

That meant this could happen:

```text
Player is in Town.
Player presses ESC.
Hidden World Map catches ESC first.
World Map opens its hidden ESC menu.
Game pauses.
Town menu never appears.
```

This made it look like Town pause worked but Town's ESC menu was missing.

## Fix

Main now disables input handling on hidden persistent views.

Only the active visible view can receive:

```text
_input
_unhandled_input
```

Town and World Map also now check whether they are the active scene before handling ESC.

## Changed Files

```text
res://scripts/main/Main.gd
res://scripts/town/Town.gd
res://scripts/world_map/WorldMap.gd
```
