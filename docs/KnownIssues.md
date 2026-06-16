# Known Issues

## v0.4.4

Known limitations:
- Only placed buildings are saved.
- Money is not saved yet.
- Adventurers are not saved yet.
- World Map simulation is not saved yet.
- Save file uses direct JSON with no migration system beyond a version field.
- Manual load removes current placed buildings and recreates them from file.
- If a building is placed somewhere valid now but future rules change, old save data may still load it.
