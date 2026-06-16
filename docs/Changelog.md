## v0.5.1.1 - Upgrade Type Inference Hotfix

### Fixed
- Fixed launch-blocking `Town.gd` parser error caused by inferred typing on `capacity_bonus`.
- Hardened upgrade capacity calculations with explicit `int` types.
- Hardened service-speed calculations with explicit `float` types.

# Changelog

## v0.5.1 - Building Upgrade Foundation

### Added
- Upgrade level per placed building.
- Upgrade cost formula.
- Upgrade Building button in building menu.
- Upgrade summary in building menu.
- Upgrade levels saved/loaded.
- General Store upgrade increases capacity and service speed.
- Inn upgrade increases capacity and service speed.
- Building labels show upgrade level.
- Building instance ID documentation.

### Changed
- Building capacity can now be affected by upgrade level.
- Service speed can now be affected by upgrade level.
- Placed building save data now includes `upgrade_level`.

### Not Yet Added
- Upgrade construction time.
- Upgrade material requirements.
- Upgrade visual changes.
- Upgrade confirmation prompt.
- Full Guild Hall upgrade effects.

## v0.5.0.1 - BuildingMenu Type Inference Hotfix

### Fixed
- Building menu worker-control launch error.

## v0.5.0 - Building Service Speed / Workers Foundation

### Added
- Service speed and worker placeholders.

## Earlier v0.4.x

- Per-building queues.
- Multi-building routing.
- Capacity.
- Save/load.
- Building placement/move/demolish/costs.
