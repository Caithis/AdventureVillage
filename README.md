# Dungeon Frontier Guild-Town

Version: v0.1.3 - Small Potion Purchase

Dungeon Frontier Guild-Town is a Godot 4.x 2D pixel-art management/simulation project about running a frontier guild-town that supports adventurers, grows its economy, and survives escalating world-map threats.

## What v0.1.3 Adds

- Adventurers attempt to buy one Small Potion when they reach the General Store.
- Small Potion has a test price of 15 gold.
- Adventurers check town potion stock.
- Adventurers check their own gold.
- If successful:
  - Adventurer gold decreases.
  - Town Small Potion stock decreases.
  - Adventurer inventory gains one Small Potion.
  - Adventurer label shows the purchase result.
- If unsuccessful:
  - Adventurer label shows why the purchase was skipped.
  - Adventurer continues to the Town Exit.

## How to Run

1. Open Godot 4.x.
2. Open/import the `godot_project/` folder.
3. Run the project.
4. Click `Spawn Adventurer`.
5. Watch the adventurer walk to the General Store.
6. The adventurer should attempt to buy a Small Potion.
7. The Debug UI potion stock should decrease if the purchase succeeds.
8. The adventurer should then walk to the Town Exit.

## Current Limitation

This is still a prototype economy interaction. There is no shop UI, no item database usage, no production system, and no world-map travel yet.
