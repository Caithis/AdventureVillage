# Changelog

## v0.1.1 - Placeholder Adventurer Spawn

### Added
- `Adventurer.tscn`.
- `Adventurer.gd`.
- `AdventurerAI.gd`.
- Enabled Spawn Adventurer button in Debug UI.
- Debug UI can request adventurer spawn through SceneRouter.
- SceneRouter can forward spawn requests to the active Town scene.
- Town scene can spawn placeholder adventurers.
- Placeholder adventurers appear as 16x16 ColorRect bodies.
- Adventurers have basic properties:
  - display name
  - class id
  - level
  - gold
  - happiness
  - health
  - inventory
- Adventurers register with GameState.
- Debug UI adventurer count updates when adventurers spawn.
- Randomized test names for spawned adventurers.

### Changed
- Town scene now includes an `Adventurers` node.
- Town scene exposes `spawn_placeholder_adventurer()`.
- Debug UI Spawn Adventurer button is no longer disabled.

### Not Yet Added
- Adventurer movement.
- General Store shopping.
- World travel.
- Combat.
- Threat clearing.

## v0.1.1.1 - Autoload Name Conflict Hotfix

### Fixed
- Removed `class_name` from `GameClock.gd`.
- Removed `class_name` from `GameState.gd`.
- Removed `class_name` from `SceneRouter.gd`.
- Fixed Godot parser error where class names hid Autoload singleton names.

### Notes
- Autoload singleton names remain unchanged in `project.godot`.
- Other scripts should still call `GameClock`, `GameState`, and `SceneRouter` normally.
