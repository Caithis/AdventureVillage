# Changelog

## v0.1.2 - Adventurer Town Routine

### Added
- Marker-based movement for placeholder adventurers.
- Basic movement speed on `Adventurer.gd`.
- Adventurer AI state flow:
  - `EnterTown`
  - `GoToGeneralStore`
  - `WaitAtGeneralStore`
  - `GoToExit`
  - `IdleAtExit`
- Adventurer labels now update as the AI state changes.
- Town scene now passes marker positions into the adventurer routine.
- Future town-building design note added to project documentation.

### Changed
- `Town.gd` now starts the adventurer town routine after spawn.
- `AdventurerAI.gd` now controls routine state transitions.
- `Adventurer.gd` now supports target movement and arrival checks.

### Not Yet Added
- Potion buying.
- Shop inventory transfer.
- Adventurer world travel.
- Combat.
- Player building placement.

## v0.1.1.1 - Autoload Name Conflict Hotfix

### Fixed
- Removed `class_name` from `GameClock.gd`.
- Removed `class_name` from `GameState.gd`.
- Removed `class_name` from `SceneRouter.gd`.
- Fixed Godot parser error where class names hid Autoload singleton names.

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
- Adventurers register with GameState.
- Debug UI adventurer count updates when adventurers spawn.

## v0.1.0 - Walking Skeleton

### Added
- Main scene.
- Town scene.
- World Map scene.
- Debug UI scene.
- GameClock autoload.
- GameState autoload.
- SceneRouter autoload.
- Scene switching.
- Placeholder town and world-map views.
