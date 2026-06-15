# Dungeon Frontier Guild-Town

Version: v0.2.1 - Return to Town With Loot

Dungeon Frontier Guild-Town is a Godot 4.x 2D pixel-art management/simulation project about running a frontier guild-town that supports adventurers, grows its economy, and survives escalating world-map threats.

## What v0.2.1 Adds

- `ReturningWithLoot` travelers now move back toward the town marker.
- `InjuredReturning` travelers now move back toward the town marker.
- Travelers that reach town change into returned-arrival states:
  - `ArrivedAtTownWithLoot`
  - `ArrivedAtTownInjured`
- GameState tracks returned traveler records.
- Debug UI shows returned traveler count.
- Debug UI shows a short returned traveler summary.
- World Map markers continue updating as travelers return.

## Important Architecture Note

The world simulation already runs through GameState, so world travelers can keep moving even if the player is not viewing the World Map.

However, the Town scene is still unloaded when switching views. Later, we should refactor Main so both Town and World Map can stay loaded at the same time, with visibility toggled or the World Map shown as an overlay.

## How to Run

1. Open Godot 4.x.
2. Open/import the `godot_project/` folder.
3. Run the project.
4. Spawn an adventurer in Town.
5. Let the adventurer buy a potion and leave town.
6. Switch to World Map.
7. Watch the traveler move to the Slime Nest.
8. Wait for combat to resolve.
9. If the traveler wins, they should return with loot.
10. If the traveler loses, they should return injured.
11. Watch the traveler move back to the town marker.
12. Confirm returned traveler count increases.

## Current Limitation

Returned travelers do not yet sell Slime Gel. They arrive back at town and are recorded as returned travelers. Selling loot is planned for v0.2.2.
