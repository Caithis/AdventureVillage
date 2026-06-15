# Economy Prototype Notes

## v0.2.4 Prototype Values

### Adventurer Purchases

Small Potion:
- Adventurer buys for 15 gold.
- Town money increases by 15.
- Town Small Potion stock decreases by 1.
- Adventurer Small Potion inventory increases by 1.

### Adventurer Loot Sales

Slime Gel:
- Adventurer sells for 5 gold each.
- Town Slime Gel stock increases by the amount sold.
- Adventurer gold increases by 5 per Slime Gel.
- Adventurer inventory Slime Gel decreases to 0.

### Current Slime Reward

One Slime victory gives:
- 2 Slime Gel

Total sale value:
- 2 Slime Gel x 5 gold = 10 gold

## Current Behavior

Returned adventurers now sell Slime Gel through a visible Town routine:
1. Spawn near Town Exit.
2. Walk to General Store.
3. Sell Slime Gel.
4. Show sale result in label.
