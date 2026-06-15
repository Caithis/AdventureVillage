# Known Issues

## v0.2.5

Known limitations:
- Repeat loop is controlled by a hardcoded max trip count.
- Adventurers do not rest at the Inn yet.
- Adventurers do not have energy/exhaustion yet.
- Night-time sleeping behavior is not implemented yet.
- Injured adventurers do not recover at the Inn yet.
- Returned adventurers do not make nuanced decisions; they follow a simple test loop.
- Slime Nest is not cleared or weakened yet.
- World traveler movement is straight-line movement.
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

This patch intentionally proves the repeat loop before adding smarter behavior. Energy, Inn rest, night behavior, and injury recovery should be layered on top after this version works.
