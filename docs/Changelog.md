# Changelog

## v0.2.5 - Basic Adventurer Loop Repeat

### Added
- Repeat adventure loop after `SoldLoot`.
- Returned adventurers wait briefly after selling.
- Returned adventurers check if they need a Small Potion.
- Returned adventurers buy another Small Potion if needed and possible.
- Returned adventurers exit town again for another Slime Nest trip.
- Prototype trip count tracking.
- Prototype max trip count.
- `PrepareNextTrip` state.
- `BuyPotionForNextTrip` state.
- `RestockedPotion` state.
- `SkipRestockNoStock` state.
- `SkipRestockNoGold` state.
- `GoToExitForNextTrip` state.
- `MaxTripsReached` state.
- Documentation note for future energy/Inn/night behavior.

### Fixed
- World-map `AwaitingTownReentry` markers are removed after Town claims the returned traveler.
- Claimed returned travelers no longer remain as active world traveler markers.

### Not Yet Added
- Inn rest.
- Energy/exhaustion.
- Night-time sleeping behavior.
- Injured recovery.
- Threat clearing.

## v0.2.4 - Returned Adventurer Re-entry

### Added
- Returned travelers are claimed by Town scene.
- Returned travelers convert back into visible `Adventurer` nodes.
- Returned adventurers spawn near the Town Exit.
- Returned adventurers sell Slime Gel through a visible town routine.

## v0.2.3 - Persistent Town/World Scene Refactor

### Added
- Main loads Town once at startup.
- Main loads World Map once at startup.
- Main keeps both views alive.
- View switching now uses visibility toggling.

## v0.2.2 - Sell Slime Gel to General Store

### Added
- Slime Gel sell value.
- Automatic Slime Gel sale when a returned traveler reaches town with loot.

## v0.2.1 - Return to Town With Loot

### Added
- Return movement for world travelers.
- Returned traveler records in `GameState`.

## v0.2.0 - First Combat Prototype

### Added
- World traveler movement toward Slime Nest.
- Simple auto-combat resolver.
- Slime Gel reward on victory.

## v0.1.x

### Added
- Walking skeleton.
- Adventurer spawning.
- Adventurer town routine.
- Small Potion purchase.
- World travel placeholder.

## v0.2.5.1 - Returned Traveler Array Crash Hotfix

### Fixed
- Fixed crash when a world traveler returned to town.
- Prevented Town from removing a world traveler while `GameState._update_world_travelers()` is still looping over `world_travelers`.
- Removed immediate `state_changed.emit()` from `_mark_traveler_arrived_at_town()`.

### Cleaned
- Fixed integer division warnings in `Town.gd`.
