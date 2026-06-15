# Known Issues

## v0.2.6

Known limitations:
- Inn rest is free.
- Inn has no capacity.
- Inn has no visible income yet.
- Night-time sleeping behavior is not implemented yet.
- Adventurers do not choose between multiple buildings or needs with weighted AI.
- Injured adventurers simply recover fully at the Inn.
- Repeat loop is still controlled by a hardcoded max trip count.
- Slime Nest is not cleared or weakened yet.
- World traveler movement is straight-line movement.
- Potion price is still hardcoded in `Adventurer.gd`.
- Slime Gel sell value is hardcoded in `GameState.gd`.
- Slime combat stats are hardcoded in `GameState.gd`.
- Purchase/sale/rest logic does not yet use data Resources.
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

This patch uses a simple state-machine approach for recovery. It is intentionally direct:
1. Sell loot.
2. Check recovery need.
3. Rest at Inn if energy is low or HP is not full.
4. Continue preparation loop.

This is enough to prove the Inn's purpose before adding night behavior or Inn economy.
