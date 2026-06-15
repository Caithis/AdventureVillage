# Changelog

## v0.2.1 - Return to Town With Loot

### Added
- Return movement for `ReturningWithLoot` travelers.
- Return movement for `InjuredReturning` travelers.
- `ArrivedAtTownWithLoot` status.
- `ArrivedAtTownInjured` status.
- Returned traveler records in `GameState`.
- Returned traveler count in Debug UI.
- Returned traveler summary in Debug UI.
- Persistent scene architecture note.

### Changed
- World traveler simulation now handles outbound travel, combat result, and return travel.
- World Map labels now show return and arrival states.

### Not Yet Added
- Loot selling.
- Re-entering the Town scene as a visible adventurer.
- Persistent Town scene while viewing the World Map.
- Threat clearing.
- Combat UI.

## v0.2.0 - First Combat Prototype

### Added
- World traveler movement toward Slime Nest.
- World traveler combat stats.
- Slime prototype stats.
- Simple auto-combat resolver.
- Small Potion usage during combat.
- Slime Gel reward on victory.
- `ReturningWithLoot` traveler status.
- `InjuredReturning` traveler status.
- Combat log text stored on traveler data.

## v0.1.4 - World Travel Placeholder

### Added
- `world_travelers` tracking in `GameState`.
- World traveler count in Debug UI.
- World traveler data creation when an adventurer leaves town.
- Placeholder world traveler markers on World Map.

### Fixed
- Successful Small Potion purchases now add 15 gold to the town treasury.
- General Store stopping points should now be more controlled.

## v0.1.3 - Small Potion Purchase

### Added
- Small Potion purchase logic.
- Small Potion test price set to 15 gold.
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
