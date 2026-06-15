# Persistent Scene Architecture Notes

## Design Goal

Eventually, the Town map and World Map should both continue simulating while the player views either one.

Example:
- Player views World Map.
- Town adventurers still shop, rest, sell loot, and move around.
- Player views Town.
- World travelers still move, fight, return, and generate threats.

## Current Architecture

Current behavior:
- Main scene switches between Town and World Map by loading one view and freeing the previous one.
- World traveler simulation lives in GameState, so world travel continues globally.
- Town adventurer node simulation only exists while the Town scene is loaded.

This is acceptable for early prototyping but not the final architecture.

## Better Future Options

### Option A: Keep Both Scenes Loaded

Main scene contains:
- TownRoot
- WorldMapRoot
- UI Layer

Switching views would hide/show scenes instead of freeing them.

Pros:
- Easy to reason about.
- Town nodes keep processing.
- World Map nodes keep processing.

Cons:
- More nodes active at once.
- Need clean camera/input handling.

### Option B: Simulation Managers + Visual Scenes

Simulation lives in managers:
- TownSimulation
- WorldSimulation
- EconomyManager
- AdventurerManager

Scenes only visualize current data.

Pros:
- Scales better.
- Better save/load.
- Easier to run simulation without visuals.

Cons:
- More abstract.
- Harder for beginner development at first.

### Recommendation

Use Option A first when we are ready to refactor:
- Keep both scenes loaded.
- Toggle visibility.
- Keep simulation simple.
- Later move deeper logic into data/managers.

Do not do this refactor until the basic loop works:
Town purchase → world travel → combat → return → sell loot.
