# Project State

## Current Version

v0.2.1 - Return to Town With Loot

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

## Current Test Flow

1. Open `godot_project/` in Godot 4.x.
2. Run the project.
3. Confirm the game starts in Town view.
4. Click `Spawn Adventurer`.
5. Let the adventurer buy a potion and leave town.
6. Confirm World Travelers count increases.
7. Switch to World Map.
8. Confirm the traveler marker appears near town.
9. Watch the traveler move toward the Slime Nest.
10. Confirm combat resolves at the Slime Nest.
11. If the traveler wins, confirm status becomes `ReturningWithLoot`.
12. If the traveler loses, confirm status becomes `InjuredReturning`.
13. Confirm the traveler moves back toward the town marker.
14. Confirm the traveler status becomes `ArrivedAtTownWithLoot` or `ArrivedAtTownInjured`.
15. Confirm Returned Travelers count increases.
16. Confirm returned traveler summary updates in Debug UI.

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

Not included:
- Loot selling
- Traveler respawning into Town scene
- Persistent Town and World Map scenes loaded at the same time
- Threat clearing
- Multiple enemies
- Multiple threat types
- Combat animation
- Combat UI
- Shop UI
- Item data Resources used in purchase logic
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

v0.2.2 - Sell Slime Gel to General Store

Planned additions:
- Returned travelers with Slime Gel sell it to the town.
- Slime Gel sell value is introduced.
- Town Slime Gel inventory increases.
- Adventurer/traveler gold increases.
- Returned traveler status changes to SoldLoot.
- Debug UI shows the sale result.
