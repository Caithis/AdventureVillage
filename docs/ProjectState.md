# Project State

## Current Version

v0.2.2 - Sell Slime Gel to General Store

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
- Debug UI displays money, inventory, in-town adventurer count, world traveler count, returned traveler count, current view, and Slime Nest status.
- Accelerated day/night clock runs.
- Spawn Adventurer button is enabled.
- Town scene can spawn placeholder adventurers.
- Spawned adventurers register with GameState.
- Spawned adventurers follow a marker-based town routine:
  - EnterTown
  - GoToGeneralStore
  - BuySmallPotion
  - BoughtPotion / SkipPurchaseNoStock / SkipPurchaseNoGold
  - GoToExit
  - LeavingTown
- Adventurers can buy one Small Potion from town stock.
- Adventurer gold decreases after a successful purchase.
- Town Small Potion stock decreases after a successful purchase.
- Town money increases by the potion price after a successful purchase.
- Adventurer inventory gains one Small Potion after a successful purchase.
- Adventurers leave the Town scene after reaching the exit.
- Exiting adventurers become world traveler data in GameState.
- World Map shows placeholder world traveler markers.
- World travelers move toward the Slime Nest.
- When a world traveler reaches the Slime Nest, simple combat resolves against one Slime.
- Adventurers use a Small Potion during combat if HP is low.
- Winning gives Slime Gel.
- Losing marks the traveler as InjuredReturning.
- ReturningWithLoot travelers move back toward town.
- InjuredReturning travelers move back toward town.
- Travelers arriving back at town become returned traveler records.
- Returned travelers with Slime Gel automatically sell it to the town.
- Town Slime Gel inventory increases after sale.
- Traveler gold increases after sale.
- Returned traveler status changes to SoldLoot.

## Current Test Flow

1. Open `godot_project/` in Godot 4.x.
2. Run the project.
3. Confirm the game starts in Town view.
4. Confirm Money starts at 500.
5. Confirm Slime Gel stock starts at 0.
6. Click `Spawn Adventurer`.
7. Let the adventurer buy a potion and leave town.
8. Confirm Money increases to 515 from the potion sale.
9. Switch to World Map.
10. Confirm the traveler moves to the Slime Nest.
11. Confirm combat resolves.
12. If the traveler wins, confirm the traveler receives 2 Slime Gel.
13. Confirm the traveler returns to the town marker.
14. Confirm the traveler status changes to SoldLoot.
15. Confirm Town Slime Gel inventory increases by 2.
16. Confirm the traveler gold increases by 10 from selling 2 Slime Gel.
17. Confirm the returned traveler summary shows the sale result.

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
- Town money increase from purchases
- Adventurer inventory increase
- World traveler data
- Placeholder world traveler markers
- World traveler movement to Slime Nest
- First combat prototype
- Potion use during combat
- Slime Gel reward
- Traveler return movement
- Returned traveler records
- Automatic Slime Gel sale to town

Not included:
- Visible returned adventurer re-entry into Town scene
- Physical General Store sell interaction
- Persistent Town and World Map scenes loaded at the same time
- Threat clearing
- Multiple enemies
- Multiple threat types
- Combat animation
- Combat UI
- Shop UI
- Item data Resources used in purchase/sale logic
- Real building placement
- Save/load
- Tilemaps
- Final pixel art

## Future Persistent Scene Direction

The long-term goal is for Town and World Map simulation to remain active at the same time.

Current state:
- World traveler simulation lives in `GameState`, so world movement continues globally.
- Town scene is still unloaded when switching to World Map.
- This means town adventurer node behavior is not truly persistent yet.

Future direction:
- Keep Town and World Map loaded under Main at the same time.
- Toggle visibility instead of destroying scenes.
- Or keep simulation fully data-driven in managers while scenes only visualize state.
- World Map may become an overlay rather than a hard scene switch.
- This should be handled after the core loop is proven.

## Next Planned Version

v0.2.3 - Persistent Town/World Scene Refactor

Planned additions:
- Main keeps Town and World Map loaded at the same time.
- Town and World Map views are hidden/shown instead of freed/reloaded.
- Town adventurers should continue moving while World Map is visible.
- World travelers should continue moving while Town is visible.
- SceneRouter changes from load/free routing to visibility routing.
