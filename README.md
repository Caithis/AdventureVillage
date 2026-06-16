# Dungeon Frontier Guild-Town

Version: v0.4.4 - Building Save / Load Foundation

## What v0.4.4 Adds

This patch starts preserving placed buildings between runs.

## Save File

Placed building data is saved to Godot user storage:

```text
user://placed_buildings.json
```

## Auto Save

Placed buildings are automatically saved after:

```text
placing a building
moving a building
demolishing a building
```

## Auto Load

When the Town scene starts, it attempts to load placed buildings from:

```text
user://placed_buildings.json
```

If no save exists yet, the game continues normally.

## Manual Save / Load Buttons

The Build Mode panel now includes:

```text
Save Buildings
Load Buildings
```

These are mainly for testing and debugging the save/load system.

## Preserved Data

Each placed building saves:

```text
building type
position
size
original cost
```

## Route Rebuild

After loading buildings, the active route markers rebuild.

That means placed General Stores and Inns should still become the active adventurer destinations after loading.

## Important Limitation

This is not a full game save system yet.

It only saves placed buildings. Money, adventurers, world slimes, time, inventory, and other systems are not fully saved yet.
