# Project State

## Current Version

v0.1.1 - Placeholder Adventurer Spawn

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
- Spawn Adventurer button is enabled.
- Town scene can spawn placeholder adventurers.
- Spawned adventurers register with GameState.
- Debug UI adventurer count updates when adventurers spawn.

## Current Test Flow

1. Open `godot_project/` in Godot 4.x.
2. Run the project.
3. Confirm the game starts in Town view.
4. Confirm the Debug UI appears in the upper-left.
5. Click `Spawn Adventurer`.
6. Confirm one placeholder adventurer appears near the town entrance.
7. Confirm the adventurer count increases.
8. Click `Spawn Adventurer` multiple times.
9. Confirm multiple adventurers appear with slight position offsets.
10. Click `World Map`.
11. Confirm the World Map view appears.
12. Click `Town`.
13. Confirm the Town view appears again.
14. Spawn another adventurer after returning to Town.

## Current Scope

Included:
- Scene routing foundation
- Debug state display
- Placeholder town scene
- Placeholder world map scene
- Placeholder Slime Nest status
- Accelerated simulation clock
- Placeholder adventurer scene
- Placeholder adventurer spawn
- Adventurer registration in GameState

Not included:
- Adventurer movement
- Adventurer AI behavior beyond idle placeholder
- Shopping behavior
- Combat
- Real building placement
- Save/load
- Tilemaps
- Final pixel art

## Next Planned Version

v0.1.2 - Adventurer Town Routine

Planned additions:
- Adventurer moves from Town Entrance to General Store.
- Adventurer waits briefly at General Store.
- Adventurer buys one Small Potion if affordable and in stock.
- Adventurer gold decreases.
- Town Small Potion stock decreases.
- Adventurer moves to Town Exit.
- Adventurer state is visible in its label or Debug UI.
