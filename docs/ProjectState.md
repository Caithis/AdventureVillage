# Project State

## Current Version

v0.1.3 - Small Potion Purchase

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
- Spawned adventurers follow a marker-based town routine:
  - EnterTown
  - GoToGeneralStore
  - BuySmallPotion
  - BoughtPotion / SkipPurchaseNoStock / SkipPurchaseNoGold
  - GoToExit
  - IdleAtExit
- Adventurers can buy one Small Potion from town stock.
- Adventurer gold decreases after a successful purchase.
- Town Small Potion stock decreases after a successful purchase.
- Adventurer inventory gains one Small Potion after a successful purchase.
- Adventurer label shows potion count.

## Current Test Flow

1. Open `godot_project/` in Godot 4.x.
2. Run the project.
3. Confirm the game starts in Town view.
4. Confirm the Debug UI appears in the upper-left.
5. Confirm Small Potion stock starts at 5.
6. Click `Spawn Adventurer`.
7. Confirm one placeholder adventurer appears near the town entrance.
8. Watch the adventurer move to the General Store marker.
9. Confirm the adventurer state changes to `BuySmallPotion`.
10. Confirm the adventurer state changes to `BoughtPotion`.
11. Confirm the adventurer gold decreases from 50 to 35.
12. Confirm the adventurer label shows `Potions: 1`.
13. Confirm Debug UI Small Potion stock decreases from 5 to 4.
14. Confirm the adventurer moves to the Town Exit marker.
15. Confirm the adventurer stops at the exit with the `IdleAtExit` state.
16. Spawn multiple adventurers and confirm potion stock decreases until empty.
17. Confirm adventurers skip purchase if town potion stock reaches 0.

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
- First shop purchase interaction
- Town inventory decrease
- Adventurer inventory increase

Not included:
- Shop UI
- Item data Resources used in purchase logic
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

v0.1.4 - World Travel Placeholder

Planned additions:
- Adventurer leaves town after reaching the Town Exit.
- GameState tracks simple world traveler data.
- World Map can show a placeholder adventurer marker.
- Adventurer marker moves toward the Slime Nest or Grassland Edge.
- Debug UI shows simple traveler count or active world travelers.
