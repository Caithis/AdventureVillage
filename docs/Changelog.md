## v0.4.5.1 - Store Capacity Timing Hotfix

### Fixed
- General Store capacity no longer releases immediately after purchase/sale logic.
- Store occupancy should now visibly increase while adventurers are in the store result state.
- Store waiting behavior should now be easier to observe.

### Changed
- Inn base capacity increased from 2 to 5.

# Changelog

## v0.4.5 - Building Capacity Foundation

### Added
- General Store customer capacity.
- Inn bed/rest capacity.
- Adventurers wait if General Store is full.
- Adventurers wait if Inn is full.
- Capacity retry behavior.
- Capacity occupancy tracking.
- Active route labels show occupancy/capacity.
- Capacity documentation.

### Fixed
- Demolishing a loaded building now saves correctly.
- Demolished building is removed from the scene tree before the save list is collected.

### Changed
- Adventurer AI now requests/release building capacity before using stores and inns.
- Adventurer exit cleanup releases any held building capacity.

### Not Yet Added
- Per-building-instance capacity.
- Building upgrades affecting capacity.
- Worker/service-speed effects.
- Visible queue lines.
- Building menu capacity details.

## v0.4.4 - Building Save / Load Foundation

### Added
- Save/load for placed buildings.

## Earlier v0.4.x

- Placed building routing.
- Building costs.
- Building movement/demolition.
- Building placement foundation.
