# Changelog

## v0.4.7 - Per-Building Instance Data Foundation

### Added
- Unique placed building instance IDs.
- Instance IDs shown on placed building labels.
- Route labels identify active building ID.
- Capacity state keyed by active building instance ID.
- Queue state keyed by active building instance ID.
- Fallback building instance IDs.
- Save/load preserves building instance IDs.
- First-pass dynamic route retargeting for adventurers in travel/queue states.
- Per-building instance data documentation.

### Fixed
- Queue markers now return to fallback store/inn after placed building demolition.
- Queue markers no longer fall back to `Vector2.ZERO` when no placed building exists.

### Not Yet Added
- True multi-building routing.
- Per-building worker assignments.
- Per-building upgrades.
- Player-selected active building.
- Capacity distribution across multiple buildings.

## v0.4.6 - Building Queue Positions

### Added
- Store and Inn queue positions.

## Earlier v0.4.x

- Capacity foundation.
- Save/load foundation.
- Routing foundation.
- Building placement/move/demolish/costs.
