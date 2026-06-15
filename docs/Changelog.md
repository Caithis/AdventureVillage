# Changelog

## v0.2.3 - Persistent Town/World Scene Refactor

### Added
- Main loads Town once at startup.
- Main loads World Map once at startup.
- Main keeps both views alive.
- View switching now uses visibility toggling.
- `SceneRouter.go_to_town()` now shows the persistent Town view.
- `SceneRouter.go_to_world_map()` now shows the persistent World Map view.
- `SceneRouter.request_spawn_adventurer()` now spawns into the persistent Town view, even if the player is looking at the World Map.
- `Main.get_view_by_name()` helper.
- `Main.show_view()` visibility routing method.

### Changed
- Main no longer frees the current view when switching scenes.
- SceneRouter no longer loads scene paths directly.
- SceneRouter now asks Main to show already-loaded views.
- Town adventurer node behavior can continue while the World Map is visible.
- World Map marker behavior can continue while the Town is visible.

### Fixed
- The Town scene no longer resets every time the player switches to World Map.
- Spawned town adventurers are no longer lost merely because the player opened World Map.

### Not Yet Added
- Returned adventurer re-entry as visible Town actors.
- Physical town-based loot selling.
- Full data-driven simulation managers.

## v0.2.2 - Sell Slime Gel to General Store

### Added
- Slime Gel sell value.
- Automatic Slime Gel sale when a returned traveler reaches town with loot.
- Town Slime Gel inventory increase after sale.
- Traveler gold increase after sale.
- `SoldLoot` returned traveler status.
- Sale result text in returned traveler summary.

## v0.2.1 - Return to Town With Loot

### Added
- Return movement for `ReturningWithLoot` travelers.
- Return movement for `InjuredReturning` travelers.
- `ArrivedAtTownWithLoot` status.
- `ArrivedAtTownInjured` status.
- Returned traveler records in `GameState`.

## v0.2.0 - First Combat Prototype

### Added
- World traveler movement toward Slime Nest.
- World traveler combat stats.
- Slime prototype stats.
- Simple auto-combat resolver.
- Small Potion usage during combat.
- Slime Gel reward on victory.

## v0.1.4 - World Travel Placeholder

### Added
- `world_travelers` tracking in `GameState`.
- World traveler count in Debug UI.
- World traveler data creation when an adventurer leaves town.

### Fixed
- Successful Small Potion purchases now add 15 gold to the town treasury.

## v0.1.3 - Small Potion Purchase

### Added
- Small Potion purchase logic.

## v0.1.2 - Adventurer Town Routine

### Added
- Marker-based movement for placeholder adventurers.

## v0.1.1.1 - Autoload Name Conflict Hotfix

### Fixed
- Removed `class_name` from Autoload scripts.

## v0.1.1 - Placeholder Adventurer Spawn

### Added
- Adventurer scene and basic spawn.

## v0.1.0 - Walking Skeleton

### Added
- Main scene, Town scene, World Map scene, Debug UI, and Autoload foundation.
