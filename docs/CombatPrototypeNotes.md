# Combat Prototype Notes

## v0.2.0 Combat Values

Adventurer:
- HP: 30
- Attack: 7
- Speed: 1.0
- Potion use threshold: 40% HP
- Small Potion heal: 15 HP

Slime:
- HP: 18
- Attack: 4
- Speed: 0.85
- Reward: 2 Slime Gel

## Current Behavior

When a world traveler reaches the Slime Nest, combat resolves instantly in `GameState.gd`.

This is temporary. Later combat should move into a dedicated system such as:
- `CombatResolver.gd`
- `WorldSimulation.gd`
- `EnemyData.gd` Resource definitions
