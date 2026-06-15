# Known Issues

## v0.2.1

Known limitations:
- Returned travelers do not sell loot yet.
- Returned travelers do not respawn as visible Town adventurers yet.
- Returned travelers remain world traveler markers at the town position.
- Slime Nest is not cleared or weakened yet.
- World traveler movement is straight-line movement.
- World traveler simulation is global, but Town scene simulation is not persistent while viewing World Map.
- Town scene is still unloaded when switching to World Map.
- Potion price is still hardcoded in `Adventurer.gd`.
- Slime combat stats are hardcoded in `GameState.gd`.
- Purchase logic does not yet use `ItemData` Resources.
- No shop UI exists.
- No animation yet.
- Multiple town adventurers may visually overlap.
- No collision avoidance.
- No roads/path preferences.
- Fixed building layout is temporary.
- No player building placement yet.
- No save/load.
- No real pixel-art sprites yet.

## Technical Notes

This patch intentionally records returned travelers instead of immediately converting them back into visible Town adventurers. This keeps the return loop testable before adding town re-entry and loot-selling behavior.
