# Dungeon Frontier Guild-Town

Version: v0.2.8 - Inn Income Prototype

## What v0.2.8 Adds

This patch makes the first real two-sided town economy loop.

### Money In

Adventurers now pay the Inn when resting or sleeping.

```text
Inn rest fee: 8 gold
Night lodging fee: 5 gold
```

If the adventurer can afford the fee:

```text
Adventurer gold decreases
Town money increases
Adventurer receives full rest
```

If the adventurer cannot afford the fee:

```text
Adventurer receives poor rest
Town money does not increase
Poor rest only partially restores HP and energy
```

### Money Out

When adventurers sell Slime Gel to the General Store, the town now pays for those materials.

```text
Slime Gel value: 5 gold each
2 Slime Gel sale: town money -10, adventurer gold +10
```

This fixes the earlier prototype issue where the adventurer gained gold but the village funds did not decrease.

## Current Economy Loop

```text
Adventurer buys Small Potion
→ Town money increases
→ Adventurer leaves town
→ Adventurer wins Slime Gel
→ Adventurer sells Slime Gel
→ Town money decreases
→ Town Slime Gel stock increases
→ Adventurer rests/sleeps at Inn
→ Town money increases
```

## Future Economy Goals Noted

Later production goals:
- Debt/loss condition if the town cannot recover from negative funds within a time limit.
- Building-level controls to disable or limit buying specific materials.
- Building menus with sliders/toggles for material purchasing behavior.
