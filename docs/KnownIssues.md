# Known Issues

## v0.1.1

Known limitations:
- Adventurers spawn but do not move yet.
- Adventurers do not persist when the Town scene is unloaded and reloaded.
- Adventurers have placeholder visuals only.
- No animation yet.
- No shop purchasing yet.
- No combat.
- No save/load.
- No real pixel-art sprites yet.

## Technical Notes

Adventurer persistence is intentionally not solved in this patch. For now, spawned adventurers belong to the active Town scene. Later, we will decide whether persistent adventurers are scene nodes, data records, or both.
