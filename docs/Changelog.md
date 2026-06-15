# Changelog

## v0.2.4 - Returned Adventurer Re-entry

### Added
- Returned travelers are claimed by Town scene.
- Returned travelers convert back into visible `Adventurer` nodes.
- Returned adventurers spawn near the Town Exit.
- Returned adventurers follow a visible return routine:
  - `ReturnedToTown`
  - `GoToGeneralStoreToSell`
  - `SellSlimeGel`
  - `SoldLoot` or `NoLootToSell`
- Adventurer can be initialized from returned traveler data.
- Visible Slime Gel selling at the General Store.
- Town Slime Gel inventory increases during visible sale.
- Adventurer gold increases during visible sale.
- Adventurer sale message appears in label.

### Changed
- Automatic world-map Slime Gel sale has been removed.
- Returned traveler arrival now creates a pending returned record for Town to process.
- `GameState` now has returned traveler claim helpers.
- `Town.gd` now listens for returned traveler records.

### Not Yet Added
- Returned adventurer repeated adventure loop.
- Resting at Inn.
- Visible shop UI.
- Resident/contracting behavior.

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
- Town Slime Gel inventory increase after sale.
- Traveler gold increase after sale.
- `SoldLoot` returned traveler status.

## v0.2.1 - Return to Town With Loot

### Added
- Return movement for `ReturningWithLoot` travelers.
- Return movement for `InjuredReturning` travelers.
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
