# Project State

## Current Version

v0.2.4 - Returned Adventurer Re-entry

## Current Working Systems

- Main scene exists.
- Town scene exists and is loaded once at startup.
- World Map scene exists and is loaded once at startup.
- Debug UI exists.
- GameClock autoload is registered.
- GameState autoload is registered.
- SceneRouter autoload is registered.
- Debug UI can switch between Town and World Map.
- Switching views hides/shows scenes instead of freeing/reloading them.
- Town scene continues processing while World Map is visible.
- World Map scene continues processing while Town is visible.
- Spawn Adventurer works even while viewing the World Map by spawning into the persistent Town scene.
- Spawned adventurers can buy one Small Potion.
- Adventurers leave town and become world travelers.
- World travelers move to the Slime Nest.
- Combat resolves against one Slime.
- Winning gives Slime Gel.
- Losing marks the traveler as injured.
- Returning travelers move back to the town marker.
- Returned travelers are claimed by the persistent Town scene.
- Returned travelers become visible town adventurers again.
- Returned adventurers spawn near the Town Exit.
- Returned adventurers walk to the General Store.
- Returned adventurers sell Slime Gel through a visible town routine.
- Town Slime Gel inventory increases after visible sale.
- Returned adventurer gold increases after visible sale.
- Returned adventurer state changes to SoldLoot.

## Current Test Flow

1. Open `godot_project/` in Godot 4.x.
2. Run the project.
3. Confirm the game starts in Town view.
4. Spawn an adventurer.
5. Let them buy a potion and leave town.
6. Switch to World Map.
7. Confirm the traveler moves to the Slime Nest.
8. Confirm combat resolves.
9. Confirm the traveler returns to town.
10. Switch to Town if you are not already there.
11. Confirm the returned traveler appears near the Town Exit.
12. Confirm the returned adventurer walks to the General Store.
13. Confirm the returned adventurer sells Slime Gel if they have any.
14. Confirm Town Slime Gel inventory increases.
15. Confirm returned adventurer gold increases.
16. Confirm returned adventurer state becomes SoldLoot or NoLootToSell.

## Current Scope

Included:
- Persistent Town and World Map scene loading
- Visibility-based view switching
- Debug state display
- Placeholder town scene
- Placeholder world map scene
- Placeholder Slime Nest status
- Accelerated simulation clock
- Placeholder adventurer spawn
- Adventurer town routine
- Potion purchase
- World travel
- Prototype combat
- Traveler return movement
- Returned traveler records
- Returned traveler visible re-entry
- Visible General Store loot sale

Not included:
- Repeat adventure loop
- Resting at Inn
- Contracting/resident adventurers
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

## Next Planned Version

v0.2.5 - Basic Adventurer Loop Repeat

Planned additions:
- After selling loot, adventurer decides whether to leave town again.
- Adventurer may buy another potion if available.
- Adventurer exits town for another Slime Nest trip.
- Prevent runaway infinite loops with a max trips value for prototype testing.
