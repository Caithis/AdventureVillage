# Project State

## Current Version

v0.2.5 - Basic Adventurer Loop Repeat

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
- Claimed returned travelers are removed from active world traveler markers.
- Returned travelers become visible town adventurers again.
- Returned adventurers spawn near the Town Exit.
- Returned adventurers walk to the General Store.
- Returned adventurers sell Slime Gel through a visible town routine.
- Town Slime Gel inventory increases after visible sale.
- Returned adventurer gold increases after visible sale.
- Returned adventurers can prepare for another trip after selling loot.
- Returned adventurers check whether they need a Small Potion.
- Returned adventurers buy a Small Potion if needed, affordable, and in stock.
- Returned adventurers leave town again for another Slime Nest trip.
- Prototype max trip count prevents endless looping.

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
10. Confirm the world-map marker is removed after Town claims the returned traveler.
11. Confirm the returned traveler appears near the Town Exit.
12. Confirm the returned adventurer walks to the General Store.
13. Confirm the returned adventurer sells Slime Gel if they have any.
14. Confirm the returned adventurer waits briefly.
15. Confirm the returned adventurer checks whether they need a potion.
16. Confirm the returned adventurer buys a potion if needed and possible.
17. Confirm the returned adventurer exits town again.
18. Confirm a new world traveler is created for the second trip.
19. Confirm the adventurer does not repeat forever after reaching the max trip count.

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
- Returned traveler visible re-entry
- Visible General Store loot sale
- Basic repeat adventure loop
- Prototype max trip count

Not included:
- Inn rest / recovery
- Energy or exhaustion
- Night-time sleeping behavior
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

## Future Energy / Inn Direction

The current repeat loop is intentionally mechanical.

Long-term intention:
- Adventurers should have energy/stamina.
- Adventuring, fighting, and travel should reduce energy.
- Low energy should make adventurers seek the Inn.
- At night, adventurers should generally seek the Inn to sleep unless they are committed to a quest or emergency activity.
- Resting should restore energy and possibly HP.
- The Inn should become an important economic driver instead of adventurers looping forever.

This is planned after the repeat loop works.

## Next Planned Version

v0.2.6 - Inn Rest / Energy Prototype

Planned additions:
- Adventurer energy value.
- Energy decreases after trips.
- Returned adventurers decide whether to rest before leaving again.
- Inn rest restores energy.
- Injured adventurers prioritize the Inn.
- Night-time behavior begins affecting adventurer decisions.
