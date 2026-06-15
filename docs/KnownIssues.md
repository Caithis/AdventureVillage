# Known Issues

## v0.2.3

Known limitations:
- Returned travelers still sell loot automatically instead of visibly entering town.
- Returned travelers do not respawn as visible Town adventurers yet.
- Returned travelers remain world traveler markers at the town position.
- Slime Nest is not cleared or weakened yet.
- World traveler movement is straight-line movement.
- Town and World Map are now both loaded, but deeper simulation is still split between scene nodes and GameState dictionaries.
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

Godot hidden nodes still process unless their processing is explicitly disabled. This patch relies on that behavior so hidden Town and World Map views can continue running.

If performance ever becomes a problem, we can move more logic into data managers and let scenes become visual-only.
