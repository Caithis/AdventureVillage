# Known Issues

## v0.1.4

Known limitations:
- World travelers are data records and placeholder markers only.
- World travelers do not move yet.
- World travelers do not fight yet.
- Adventurers are removed from the Town scene after exit, so their town node no longer exists.
- Potion price is still hardcoded in `Adventurer.gd`.
- Purchase logic does not yet use `ItemData` Resources.
- No shop UI exists.
- No animation yet.
- Movement is straight-line movement, not pathfinding.
- Multiple adventurers may visually overlap.
- No collision avoidance.
- No roads/path preferences.
- Fixed building layout is temporary.
- No player building placement yet.
- No save/load.
- No real pixel-art sprites yet.

## Technical Notes

World traveler data currently stores:
- ID
- name
- class
- level
- gold
- inventory
- status

This will eventually need to become a stronger data model, likely with Resource-backed adventurer data or a dedicated AdventurerRecord structure.
