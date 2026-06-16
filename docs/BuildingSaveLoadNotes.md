# Building Save / Load Foundation

## v0.4.4 Implementation

Placed buildings are now saved as JSON.

## Save Path

```text
user://placed_buildings.json
```

Godot stores `user://` data outside the project folder.

## Saved Data

Each placed building saves:

```text
building_type
position_x
position_y
size_x
size_y
original_cost
```

## Auto Save Events

The game auto-saves placed buildings after:

```text
place
move
demolish
```

## Auto Load

The Town scene loads saved placed buildings during `_ready()`.

## Route Rebuild

After load, the Town scene rebuilds:

```text
General Store route marker
Inn route marker
```

## Current Limitations

This is not a full save system.

Not yet saved:
- money
- inventory
- clock/day
- adventurers
- world travelers
- world slimes
- quest state
- building upgrades
- building workers

## Future Direction

Eventually, save/load should move into a dedicated SaveManager autoload that saves the entire game state.
