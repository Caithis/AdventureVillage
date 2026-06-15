# Project State

## Current Version

v0.2.3 - Persistent Town/World Scene Refactor

## Godot Version

Target: Godot 4.x stable

## Current Working Systems

- Main scene exists.
- Town scene exists and is loaded once at startup.
- World Map scene exists and is loaded once at startup.
- Debug UI exists.
- GameClock autoload is registered.
- GameState autoload is registered.
- SceneRouter autoload is registered.
- Debug UI can switch between Town and World Map.
- Switching views now hides/shows scenes instead of freeing/reloading them.
- Town scene continues processing while World Map is visible.
- World Map scene continues processing while Town is visible.
- Debug UI displays money, inventory, in-town adventurer count, world traveler count, returned traveler count, current view, and Slime Nest status.
- Accelerated day/night clock runs.
- Spawn Adventurer button is enabled.
- Spawn Adventurer works even while viewing the World Map by spawning into the persistent Town scene.
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
4. Click `Spawn Adventurer`.
5. Immediately click `World Map`.
6. Confirm the current view changes to World Map.
7. Wait while viewing the World Map.
8. Confirm the in-town adventurer count eventually decreases.
9. Confirm the world traveler count increases.
10. Confirm a traveler marker appears on the World Map.
11. Confirm the traveler moves to the Slime Nest.
12. Confirm combat resolves.
13. Confirm the traveler returns to town.
14. Confirm the traveler sells Slime Gel if they won.
15. Switch back to Town and confirm the Town scene did not reload from scratch.
16. Spawn more adventurers from either Town or World Map view.

## Current Scope

Included:
- Scene routing foundation
- Persistent Town and World Map scene loading
- Visibility-based view switching
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

## Architecture Notes

This patch intentionally keeps both major views loaded.

Main now owns:
- Town view
- World Map view
- UI layer

SceneRouter now requests view visibility changes rather than loading/freeing scenes.

This is closer to the intended final game, where the town and world should both continue running regardless of which one the player is currently watching.

## Next Planned Version

v0.2.4 - Returned Adventurer Re-entry

Planned additions:
- Returned traveler records convert back into visible town adventurers.
- Returned adventurers enter from the town/world exit.
- Returned adventurers walk to the General Store.
- Returned adventurers sell loot through a visible town routine instead of automatic world-map sale.
- Automatic sale may be removed or changed into a temporary fallback.
