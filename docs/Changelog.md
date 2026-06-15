# Changelog

## v0.2.0 - First Combat Prototype

### Added
- World traveler movement toward Slime Nest.
- World traveler combat stats:
  - HP
  - max HP
  - attack
  - speed
- Slime prototype stats:
  - HP
  - attack
  - speed
- Simple auto-combat resolver.
- Small Potion usage during combat when adventurer HP is low.
- Slime Gel reward on victory.
- `ReturningWithLoot` traveler status.
- `InjuredReturning` traveler status.
- Combat log text stored on traveler data.
- World Map marker label now displays:
  - traveler name
  - status
  - HP
  - potion count
  - Slime Gel count
- Debug UI now includes a short world traveler status summary.

### Changed
- World traveler data now starts with combat stats.
- World traveler markers now update continuously while on the World Map.
- Slime Nest is now an actual prototype target rather than only a static marker.

### Not Yet Added
- Return-to-town movement.
- Loot selling.
- Threat clearing.
- Combat animation.
- Combat UI.
- Multiple enemies.
- Multiple threat types.

## v0.1.4 - World Travel Placeholder

### Added
- `world_travelers` tracking in `GameState`.
- World traveler count in Debug UI.
- World traveler data creation when an adventurer leaves town.
- Placeholder world traveler markers on World Map.
- `LeavingTown` adventurer AI state.
- Adventurer cleanup after reaching Town Exit.

### Fixed
- Successful Small Potion purchases now add 15 gold to the town treasury.
- General Store stopping points should now be more controlled.

## v0.1.3 - Small Potion Purchase

### Added
- Small Potion purchase logic.
- Small Potion test price set to 15 gold.
- Adventurer purchase states.
- Adventurer checks town Small Potion stock and personal gold.
- Adventurer loses gold after successful purchase.
- Town Small Potion stock decreases after successful purchase.
- Adventurer inventory gains `small_potion`.

## v0.1.2 - Adventurer Town Routine

### Added
- Marker-based movement for placeholder adventurers.
- Basic movement speed on `Adventurer.gd`.
- Adventurer AI state flow.

## v0.1.1.1 - Autoload Name Conflict Hotfix

### Fixed
- Removed `class_name` from Autoload scripts.

## v0.1.1 - Placeholder Adventurer Spawn

### Added
- Adventurer scene and basic spawn.

## v0.1.0 - Walking Skeleton

### Added
- Main scene, Town scene, World Map scene, Debug UI, and Autoload foundation.
