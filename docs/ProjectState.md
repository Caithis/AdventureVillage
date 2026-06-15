# Project State

## Current Version

v0.2.0 - First Combat Prototype

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
- Debug UI displays money, inventory, in-town adventurer count, world traveler count, current view, and Slime Nest status.
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
- World Map shows placeholder world traveler markers near the town marker.
- World travelers move toward the Slime Nest.
- When a world traveler reaches the Slime Nest, simple combat resolves against one Slime.
- Adventurers use a Small Potion during combat if HP is low.
- Winning gives Slime Gel.
- Losing marks the traveler as InjuredReturning.

## Current Test Flow

1. Open `godot_project/` in Godot 4.x.
2. Run the project.
3. Confirm the game starts in Town view.
4. Confirm money starts at 500.
5. Confirm Small Potion stock starts at 5.
6. Click `Spawn Adventurer`.
7. Let the adventurer walk to General Store and buy a potion.
8. Confirm money increases by 15.
9. Let the adventurer walk to Town Exit and leave town.
10. Confirm World Travelers count increases.
11. Switch to World Map.
12. Confirm the traveler marker appears near town.
13. Watch the traveler move toward the Slime Nest.
14. Confirm the traveler status changes to FightingSlime when it reaches the nest.
15. Confirm combat resolves.
16. If the traveler wins, confirm status becomes ReturningWithLoot and Slime Gel count appears in marker label.
17. If the traveler loses, confirm status becomes InjuredReturning.
18. Confirm potion count decreases if a potion was used during combat.

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
- World traveler movement
- First combat prototype
- Potion use during combat
- Slime Gel reward

Not included:
- Return-to-town movement
- Loot selling
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

## Next Planned Version

v0.2.1 - Return to Town With Loot

Planned additions:
- ReturningWithLoot travelers move back toward the town marker.
- InjuredReturning travelers also move back toward town.
- Returning travelers become town arrivals again or convert into returning adventurer data.
- Adventurer sells Slime Gel to the General Store.
- Town Slime Gel stock increases.
- Adventurer gold increases from selling loot.
