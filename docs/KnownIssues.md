# Known Issues

## v0.4.7

Known limitations:
- The newest placed building of a type is still the active route.
- Multiple stores/inns do not yet split customers.
- Per-building state exists, but routing does not yet distribute across all instances.
- Adventurers already in a service state may finish before using the updated route.
- Save/load covers placed building instance IDs, but not full game state.
