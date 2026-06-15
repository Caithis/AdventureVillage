# Known Issues

## v0.2.0

Known limitations:
- Combat resolves instantly when a traveler reaches the Slime Nest.
- Travelers do not return to town yet.
- Travelers do not sell loot yet.
- Slime Nest is not cleared or weakened yet.
- World traveler movement is straight-line movement.
- World traveler movement only happens while the game is running, but it is managed globally by GameState.
- World Map markers are rebuilt on state updates and updated each frame while World Map is visible.
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

Combat is intentionally placed in `GameState.gd` for this prototype because world travelers are currently stored as dictionaries. This should eventually be refactored into a dedicated combat resolver or world simulation manager once the loop is proven.
