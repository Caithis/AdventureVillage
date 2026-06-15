# Known Issues

## v0.1.2

Known limitations:
- Adventurers move but do not buy items yet.
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

The current movement system is intentionally simple. It proves that an adventurer can receive town marker positions and follow an AI routine. Pathfinding and road-aware movement should wait until the town-building grid is designed.
