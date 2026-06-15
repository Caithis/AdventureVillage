# Project State

## Current Version

v0.1.2 - Adventurer Town Routine

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
- Spawned adventurers now follow a marker-based town routine:
  - EnterTown
  - GoToGeneralStore
  - WaitAtGeneralStore
  - GoToExit
  - IdleAtExit

## Current Test Flow

1. Open `godot_project/` in Godot 4.x.
2. Run the project.
3. Confirm the game starts in Town view.
4. Confirm the Debug UI appears in the upper-left.
5. Click `Spawn Adventurer`.
6. Confirm one placeholder adventurer appears near the town entrance.
7. Confirm the adventurer count increases.
8. Watch the adventurer move to the General Store marker.
9. Confirm the adventurer waits briefly at the General Store.
10. Confirm the adventurer moves to the Town Exit marker.
11. Confirm the adventurer stops at the exit with the `IdleAtExit` state.
12. Spawn multiple adventurers and confirm each follows the routine.
13. Confirm Town / World Map switching still works.
14. Confirm Add Money, Add Slime Gel, and Grow Slime Nest still work.

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
- Marker-based adventurer movement
- Basic adventurer AI state routine

Not included:
- Potion buying
- Adventurer inventory UI
- World-map travel marker
- Combat
- Real building placement
- Save/load
- Tilemaps
- Final pixel art

## Future Town-Building Direction

The current fixed building layout is temporary.

Long-term intention:
- The player starts with an open buildable town area.
- The player places the Guild Hall.
- The tutorial then guides the player to place the Inn and General Store.
- Buildings should be movable after placement.
- Roads and decorations should be placeable.
- The town should expand over time through purchasable land plots from the kingdom.
- The village should feel player-created, not pre-built.

This is intentionally deferred until core functionality is stable.

## Next Planned Version

v0.1.3 - Small Potion Purchase

Planned additions:
- Adventurer checks town Small Potion stock.
- Adventurer checks their own gold.
- Adventurer buys one Small Potion if affordable and available.
- Town Small Potion stock decreases.
- Adventurer gold decreases.
- Adventurer inventory gains Small Potion.
- Label/debug text reflects purchase result.
