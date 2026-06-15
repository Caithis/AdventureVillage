# Dungeon Frontier Guild-Town

Version: v0.2.2 - Sell Slime Gel to General Store

Dungeon Frontier Guild-Town is a Godot 4.x 2D pixel-art management/simulation project about running a frontier guild-town that supports adventurers, grows its economy, and survives escalating world-map threats.

## What v0.2.2 Adds

- Returned travelers with Slime Gel now sell it to the town automatically.
- Slime Gel sell value is introduced.
- Town Slime Gel inventory increases after sale.
- Traveler gold increases after sale.
- Returned traveler status changes to `SoldLoot`.
- Debug UI shows sale result in the returned traveler summary.
- World Map marker label reflects the sold-loot status.

## Prototype Economy Values

- Small Potion buy price: 15 gold
- Slime Gel sell value: 5 gold each
- Slime reward: 2 Slime Gel
- Total return sale from one Slime victory: 10 gold

## How to Run

1. Open Godot 4.x.
2. Open/import the `godot_project/` folder.
3. Run the project.
4. Spawn an adventurer in Town.
5. Let the adventurer buy a potion and leave town.
6. Switch to World Map.
7. Watch the traveler move to the Slime Nest.
8. Wait for combat to resolve.
9. If the traveler wins, they return with Slime Gel.
10. When they reach town, they automatically sell the Slime Gel.
11. Confirm Town Slime Gel inventory increases.
12. Confirm the traveler status becomes `SoldLoot`.

## Current Limitation

The sale is automatic and does not yet happen through a visible General Store interaction. Later, returned travelers should physically re-enter town, visit the General Store, sell loot, then decide whether to rest, shop again, or leave.
