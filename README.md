# Dungeon Frontier Guild-Town

Version: v0.1.4 - World Travel Placeholder

Dungeon Frontier Guild-Town is a Godot 4.x 2D pixel-art management/simulation project about running a frontier guild-town that supports adventurers, grows its economy, and survives escalating world-map threats.

## What v0.1.4 Adds

- Adventurers now leave the Town scene after reaching the Town Exit.
- Exiting adventurers become world traveler data stored in `GameState`.
- World Map displays placeholder traveler markers near the town marker.
- Debug UI shows active world traveler count.
- Potion purchases now add gold to the town treasury.
- General Store stopping behavior has been tightened with queue-style target offsets.

## How to Run

1. Open Godot 4.x.
2. Open/import the `godot_project/` folder.
3. Run the project.
4. Click `Spawn Adventurer`.
5. Adventurer should walk to the General Store.
6. If potions are available, the adventurer buys one.
7. Town money should increase by 15 after a successful purchase.
8. Adventurer should walk to the Town Exit.
9. Adventurer should leave the Town scene.
10. World traveler count should increase.
11. Switch to World Map.
12. A placeholder traveler marker should appear near the town marker.

## Current Limitation

World travelers are only placeholder data and markers. They do not yet move toward the Slime Nest or fight.
