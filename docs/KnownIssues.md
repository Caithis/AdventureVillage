# Known Issues

## v0.1.3

Known limitations:
- Adventurers buy only one potion.
- Potion price is hardcoded in `Adventurer.gd`.
- Purchase logic does not yet use `ItemData` Resources.
- No shop UI exists.
- Adventurers do not persist when the Town scene is unloaded and reloaded.
- Adventurers have placeholder visuals only.
- No animation yet.
- Movement is straight-line movement, not pathfinding.
- Multiple adventurers may visually overlap.
- No collision avoidance.
- No roads/path preferences.
- Fixed building layout is temporary.
- No player building placement yet.
- No combat.
- No save/load.
- No real pixel-art sprites yet.

## Technical Notes

The purchase logic is intentionally hardcoded for now because the goal is to prove the gameplay loop before building a flexible shop/economy architecture.
