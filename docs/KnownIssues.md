# Known Issues

## v0.2.4

Known limitations:
- Returned adventurers sell loot and then idle at the General Store.
- Returned adventurers do not leave again yet.
- Returned adventurers do not rest at the Inn.
- Injured adventurers do not have recovery behavior yet.
- Returned traveler records remain in `GameState.returned_travelers` for summary/debugging.
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

This patch deliberately moves loot selling into the Town scene so returning adventurers become visible again. This creates a stronger foundation for future routines: rest, shop, contract, leave again, or become residents.
