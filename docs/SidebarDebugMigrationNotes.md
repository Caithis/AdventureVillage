# Sidebar Debug Migration Notes

## v0.6.09 Hotfix 1

The legacy top-left Debug UI has been disabled.

Debug controls now live in the right sidebar Debug tab.

## Why

The old overlay covered the playfield and cluttered the screen.

The sidebar is a better temporary home for testing controls.

## Current Debug Controls

```text
Town
World
+Gold
+Gel
Nest+
Spawn
Night
BuyGel
Refresh
```

## Future Direction

The final player-facing game should not expose most debug tools.

They can eventually move behind:
- developer mode
- debug hotkey
- hidden test panel
- editor-only tools
