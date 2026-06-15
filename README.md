# Dungeon Frontier Guild-Town

Version: v0.1.1 - Placeholder Adventurer Spawn

Dungeon Frontier Guild-Town is a Godot 4.x 2D pixel-art management/simulation project about running a frontier guild-town that supports adventurers, grows its economy, and survives escalating world-map threats.

## What v0.1.1 Adds

- `Adventurer.tscn`
- `Adventurer.gd`
- `AdventurerAI.gd`
- Enabled `Spawn Adventurer` button.
- Spawned a 16x16 placeholder adventurer in the Town scene.
- Registered spawned adventurers with `GameState`.
- Updated Debug UI adventurer count.
- Added basic randomized adventurer names.
- Added adventurer labels and simple placeholder body visuals.

## How to Run

1. Open Godot 4.x.
2. Open/import the `godot_project/` folder.
3. Run the project.
4. The project should start in Town view.
5. Click `Spawn Adventurer`.
6. A small placeholder adventurer should appear near the town entrance.
7. The Debug UI adventurer count should increase.

## Current Limitation

Adventurers spawn but do not walk or shop yet. Movement and General Store interaction are planned for v0.1.2.
