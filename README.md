# Dungeon Frontier Guild-Town

Version: v0.1.2 - Adventurer Town Routine

Dungeon Frontier Guild-Town is a Godot 4.x 2D pixel-art management/simulation project about running a frontier guild-town that supports adventurers, grows its economy, and survives escalating world-map threats.

## What v0.1.2 Adds

- Spawned adventurers now walk through a simple town routine.
- Marker-based movement using Town markers.
- Basic movement speed.
- AI state progression:
  - EnterTown
  - GoToGeneralStore
  - WaitAtGeneralStore
  - GoToExit
  - IdleAtExit
- Adventurer label updates with current state.
- No potion buying yet. Economy interaction begins after movement is stable.

## How to Run

1. Open Godot 4.x.
2. Open/import the `godot_project/` folder.
3. Run the project.
4. Click `Spawn Adventurer`.
5. The adventurer should appear at the Town Entrance.
6. The adventurer should walk to the General Store.
7. The adventurer should wait briefly.
8. The adventurer should walk to the Town Exit.
9. The adventurer should stop at the exit.

## Current Limitation

Adventurers do not buy items yet. The fixed building layout is still temporary. Later, the player will place and move buildings, roads, decorations, and expanded land plots.
