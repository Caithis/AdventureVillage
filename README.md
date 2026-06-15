# Dungeon Frontier Guild-Town

Version: v0.2.3 - Persistent Town/World Scene Refactor

Dungeon Frontier Guild-Town is a Godot 4.x 2D pixel-art management/simulation project about running a frontier guild-town that supports adventurers, grows its economy, and survives escalating world-map threats.

## What v0.2.3 Adds

- Main now loads Town once at startup.
- Main now loads World Map once at startup.
- SceneRouter now shows/hides views instead of freeing and reloading scenes.
- Town adventurers continue processing while the World Map is visible.
- World travelers continue processing while the Town is visible.
- Spawn Adventurer now works even while viewing the World Map by spawning into the persistent Town scene.
- Debug UI still switches between Town and World Map.

## Why This Matters

Earlier versions destroyed the Town scene when switching to the World Map. That was fine for early prototyping, but it would eventually break the intended game design because town adventurers should keep shopping, walking, and leaving town while the player watches the World Map.

This refactor moves the project closer to the intended final structure.

## How to Run

1. Open Godot 4.x.
2. Open/import the `godot_project/` folder.
3. Run the project.
4. Spawn an adventurer in Town.
5. Immediately switch to World Map.
6. Wait.
7. The hidden Town scene should keep processing.
8. The adventurer should eventually leave town and become a world traveler.
9. World traveler count should increase while you are still on the World Map.
10. The traveler should move to the Slime Nest, fight, return, and sell loot.

## Current Limitation

This keeps both scenes loaded, but the deeper simulation is still mixed between scene nodes and GameState dictionaries. Later we should move toward cleaner data-driven managers for adventurers, buildings, economy, threats, and world simulation.
