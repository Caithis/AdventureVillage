# Known Issues

## v0.2.2

Known limitations:
- Returned travelers sell loot automatically instead of visibly entering town.
- Returned travelers do not respawn as visible Town adventurers yet.
- Returned travelers remain world traveler markers at the town position.
- Slime Nest is not cleared or weakened yet.
- World traveler movement is straight-line movement.
- World traveler simulation is global, but Town scene simulation is not persistent while viewing World Map.
- Town scene is still unloaded when switching to World Map.
- Potion price is still hardcoded in `Adventurer.gd`.
- Slime Gel sell value is hardcoded in `GameState.gd`.
- Slime combat stats are hardcoded in `GameState.gd`.
- Purchase/sale logic does not yet use `ItemData` Resources.
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

The automatic sale is a prototype shortcut. The intended future behavior is:
1. Traveler returns to town.
2. Traveler becomes a visible town adventurer again.
3. Traveler walks to the General Store.
4. Traveler sells loot.
5. Town gains material stock.
6. Adventurer gains gold.
7. Adventurer decides whether to rest, shop, leave again, or become contractable.
