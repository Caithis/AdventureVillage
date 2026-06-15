# Project State

## Current Version

v0.1.4 - World Travel Placeholder

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

## Current Test Flow

1. Open `godot_project/` in Godot 4.x.
2. Run the project.
3. Confirm the game starts in Town view.
4. Confirm the Debug UI appears in the upper-left.
5. Confirm money starts at 500.
6. Confirm Small Potion stock starts at 5.
7. Confirm World Travelers starts at 0.
8. Click `Spawn Adventurer`.
9. Confirm one placeholder adventurer appears near the town entrance.
10. Watch the adventurer move to the General Store marker.
11. Confirm the adventurer buys a potion if stock is available.
12. Confirm money increases by 15 after purchase.
13. Confirm Small Potion stock decreases by 1 after purchase.
14. Confirm the adventurer moves to the Town Exit marker.
15. Confirm the adventurer leaves the Town scene.
16. Confirm in-town adventurer count decreases.
17. Confirm World Travelers count increases.
18. Switch to World Map.
19. Confirm a placeholder traveler marker appears near the town marker.
20. Spawn multiple adventurers and confirm multiple world traveler markers appear.

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

Not included:
- World traveler movement
- Slime Nest targeting
- Combat
- Shop UI
- Item data Resources used in purchase logic
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

v0.2.0 - First Combat Prototype

Planned additions:
- World traveler marker moves toward Slime Nest.
- One Slime enemy is created as combat data.
- Basic auto-combat resolver.
- Adventurer uses Small Potion if health is low.
- Combat result is shown in Debug UI or marker label.
- Winning gives Slime Gel.
