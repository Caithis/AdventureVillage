## v0.5.0.1 - BuildingMenu Type Inference Hotfix

### Fixed
- Fixed launch-blocking `BuildingMenu.gd` parser error caused by Godot being unable to infer the type of `can_adjust_workers`.
- Added explicit bool typing for worker/service menu visibility checks.

# Changelog

## v0.5.0 - Building Service Speed / Workers Foundation

### Added
- Base service time per service building type.
- General Store service duration.
- Inn rest service duration.
- Worker placeholder count per building.
- Worker speed bonus effect.
- Building labels show service time and worker count.
- Building menu shows service summary.
- Add Worker Placeholder button.
- Remove Worker Placeholder button.
- Placed building worker counts save/load.
- Service speed / worker documentation.

### Changed
- General Store purchase/sale service wait now uses building service speed.
- Inn rest wait now uses building service speed.
- Store and Inn labels now show more local service information.

### Not Yet Added
- Real worker NPCs.
- Hiring/wages.
- Worker schedules.
- Worker skill/quality.
- Service speed upgrades.
- Worker assignment by job category.

## v0.4.9 - Per-Building Queue Visuals

### Added
- Per-building local queue visuals.

## Earlier v0.4.x

- Multi-building routing.
- Per-building instance IDs.
- Capacity.
- Save/load.
- Building placement/move/demolish/costs.
