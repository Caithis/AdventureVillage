# Combat Prototype Notes

## v0.2.1 Combat and Return Behavior

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

1. Traveler moves from town marker to Slime Nest.
2. Combat resolves instantly on arrival.
3. If the traveler wins:
   - Status becomes `ReturningWithLoot`.
   - Inventory gains 2 Slime Gel.
   - Traveler returns to town marker.
   - Status becomes `ArrivedAtTownWithLoot`.
4. If the traveler loses:
   - Status becomes `InjuredReturning`.
   - Traveler returns to town marker.
   - Status becomes `ArrivedAtTownInjured`.

## Next Step

v0.2.2 should make returned travelers sell Slime Gel to the town.
