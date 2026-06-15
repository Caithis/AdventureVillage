# Changelog

## v0.2.6 - Inn Rest / Energy Prototype

### Added
- Adventurer energy value.
- Adventurer max energy value.
- World trip energy cost.
- Low-energy threshold.
- Energy display in adventurer labels.
- HP display in adventurer labels.
- Returned adventurer recovery check.
- `CheckRecoveryNeed` state.
- `GoToInn` state.
- `RestAtInn` state.
- `RestedAtInn` state.
- `SkipInnRest` state.
- Low-energy adventurers walk to Inn before leaving again.
- Injured adventurers prioritize Inn recovery.
- Inn rest restores HP and energy.
- Inn marker is passed into returned adventurer routines.
- Documentation for future night/Inn behavior.

### Changed
- Returned adventurers now evaluate recovery needs before the next trip.
- World traveler data now stores energy and max energy.
- Combat/return flow now applies world trip fatigue.

### Not Yet Added
- Paid Inn stays.
- Night sleep behavior.
- Inn capacity.
- Injury severity.
- Detailed rest duration.

## v0.2.5.1 - Returned Traveler Array Crash Hotfix

### Fixed
- Fixed crash when a world traveler returned to town.
- Prevented Town from removing a world traveler while `GameState._update_world_travelers()` is still looping over `world_travelers`.
- Fixed integer division warnings in `Town.gd`.

## v0.2.5 - Basic Adventurer Loop Repeat

### Added
- Repeat adventure loop after `SoldLoot`.
- Returned adventurers wait briefly after selling.
- Returned adventurers buy another Small Potion if needed and possible.
- Prototype trip count tracking.
- Prototype max trip count.

## v0.2.4 - Returned Adventurer Re-entry

### Added
- Returned travelers convert back into visible `Adventurer` nodes.
- Returned adventurers sell Slime Gel through a visible town routine.

## v0.2.3 - Persistent Town/World Scene Refactor

### Added
- Town and World Map stay loaded at the same time.

## v0.2.2 - Sell Slime Gel to General Store

### Added
- Slime Gel sell value.

## v0.2.1 - Return to Town With Loot

### Added
- Return movement for world travelers.

## v0.2.0 - First Combat Prototype

### Added
- World traveler movement and simple combat.

## v0.1.x

### Added
- Walking skeleton, adventurer spawning, town routine, potion purchase, and world travel placeholder.
