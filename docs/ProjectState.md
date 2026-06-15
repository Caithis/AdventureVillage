# Project State

## Current Version

v0.1.0 - Walking Skeleton

## Godot Version

Target: Godot 4.x stable

## Current Working Systems

- Main scene exists.
- Town scene exists.
- World Map scene exists.
- Debug UI exists.
- GameClock autoload is registered.
- GameState autoload is registered.
- SceneRouter autoload is registered.
- Debug UI can switch between Town and World Map.
- Debug UI displays money, inventory, adventurer count, current view, and Slime Nest status.
- Accelerated day/night clock runs.

## Current Test Flow

1. Open `godot_project/` in Godot 4.x.
2. Run the project.
3. Confirm the game starts in Town view.
4. Confirm the Debug UI appears in the upper-left.
5. Confirm the clock moves and switches between Day and Night.
6. Click `World Map`.
7. Confirm the World Map view appears.
8. Click `Town`.
9. Confirm the Town view appears.
10. Click `Add 25 Money`.
11. Confirm money increases.
12. Click `Add Slime Gel`.
13. Confirm Slime Gel count increases.
14. Click `Grow Slime Nest`.
15. Confirm Slime Nest status/growth updates.

## Current Scope

Included:
- Scene routing foundation
- Debug state display
- Placeholder town scene
- Placeholder world map scene
- Placeholder Slime Nest status
- Accelerated simulation clock

Not included:
- Adventurer sprite/entity
- Adventurer AI
- Shopping behavior
- Combat
- Real building placement
- Save/load
- Tilemaps
- Art pipeline

## Next Planned Version

v0.1.1 - Placeholder Adventurer Spawn

Planned additions:
- Adventurer.tscn
- Adventurer.gd
- AdventurerAI.gd
- Spawn Adventurer button should create one placeholder adventurer in Town.
- Adventurer should register with GameState.
- Adventurer should move between Town entrance, General Store, and Town exit.
