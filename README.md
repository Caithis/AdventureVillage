# Dungeon Frontier Guild-Town

Version: v0.2.0 - First Combat Prototype

Dungeon Frontier Guild-Town is a Godot 4.x 2D pixel-art management/simulation project about running a frontier guild-town that supports adventurers, grows its economy, and survives escalating world-map threats.

## What v0.2.0 Adds

- World travelers now move toward the Slime Nest.
- Slime enemy prototype data exists in code.
- Simple auto-combat resolves when a traveler reaches the Slime Nest.
- Adventurers have combat stats:
  - HP
  - max HP
  - attack
  - speed
- Slime has combat stats:
  - HP
  - attack
  - speed
- Adventurers use one Small Potion if HP drops low enough.
- If the adventurer wins:
  - They gain Slime Gel.
  - Their status changes to ReturningWithLoot.
- If the adventurer loses:
  - Their status changes to InjuredReturning.
- World Map traveler markers update with status, HP, and inventory.

## How to Run

1. Open Godot 4.x.
2. Open/import the `godot_project/` folder.
3. Run the project.
4. Spawn an adventurer in Town.
5. Let the adventurer buy a potion and leave town.
6. Switch to World Map.
7. Watch the traveler move toward the Slime Nest.
8. When the traveler reaches the Slime Nest, combat resolves.
9. Check the traveler marker label for result.

## Current Limitation

Combat resolves instantly once the traveler reaches the Slime Nest. This is intentional for the first combat prototype. Later patches can add visible turn-by-turn combat, return-to-town travel, injury recovery, loot selling, and threat-clearing logic.
