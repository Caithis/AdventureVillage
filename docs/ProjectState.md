# Project State

## Current Version

v0.2.6 - Inn Rest / Energy Prototype

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
- Spawn Adventurer works even while viewing the World Map.
- Spawned adventurers can buy one Small Potion.
- Adventurers leave town and become world travelers.
- World travelers move to the Slime Nest.
- Combat resolves against one Slime.
- Winning gives Slime Gel.
- Losing marks the traveler as injured.
- World trips reduce adventurer energy.
- Returning travelers move back to the town marker.
- Returned travelers are claimed by the persistent Town scene.
- Claimed returned travelers are removed from active world traveler markers.
- Returned travelers become visible town adventurers again.
- Returned adventurers spawn near the Town Exit.
- Returned adventurers walk to the General Store.
- Returned adventurers sell Slime Gel through a visible town routine.
- Returned adventurers check HP and energy before leaving again.
- Low-energy adventurers walk to the Inn.
- Injured adventurers prioritize the Inn.
- Inn rest restores energy.
- Inn rest restores HP.
- Rested adventurers return to preparation and can leave again.
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
9. Confirm energy decreases after the world trip.
10. Confirm the traveler returns to town.
11. Confirm the returned traveler appears near the Town Exit.
12. Confirm the returned adventurer walks to the General Store.
13. Confirm the returned adventurer sells Slime Gel if they have any.
14. Confirm the returned adventurer checks recovery needs.
15. Confirm low-energy or injured adventurer walks to the Inn.
16. Confirm the adventurer rests at the Inn.
17. Confirm HP and energy are restored.
18. Confirm the adventurer returns to the preparation loop.
19. Confirm the adventurer can buy another potion and leave again if below max trip count.

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
- Energy system
- Inn rest prototype
- Injured recovery priority

Not included:
- Paid Inn stays
- Inn capacity
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

## Future Night / Inn Direction

The current Inn behavior is recovery-based.

Long-term intention:
- Adventurers should seek the Inn at night if they are free.
- Adventurers already on quests may continue.
- Night may increase danger.
- Inn should generate money from lodging.
- Better Inns should improve recovery, happiness, and town attractiveness.

## Next Planned Version

v0.2.7 - Night Sleep Behavior

Planned additions:
- Free adventurers detect Night from GameClock.
- Free/idle adventurers seek the Inn at night.
- Adventurers currently on quests continue unless low energy or injured.
- Inn rest/sleep behavior becomes tied to day/night.

## v0.2.7 Update Notes

Night sleep behavior is now active for free/preparing town adventurers.

Current rest thresholds:
- HP at or below 50%.
- Energy at or below 40%.

Night sleep overrides those thresholds when the adventurer is free/preparing. Adventurers already committed to world travel or quest behavior continue for now.

## v0.2.8 Update Notes

Economy changes:
- Small Potion sales increase town money.
- Slime Gel purchases now decrease town money.
- Inn rest increases town money if the adventurer can pay.
- Night lodging increases town money if the adventurer can pay.
- Poor rest/sleep occurs if the adventurer cannot pay.

Future economy goals recorded:
- Debt / bankruptcy loss condition.
- Building-level material purchasing controls.
