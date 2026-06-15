# Dungeon Frontier Guild-Town

Version: v0.2.6 - Inn Rest / Energy Prototype

Dungeon Frontier Guild-Town is a Godot 4.x 2D pixel-art management/simulation project about running a frontier guild-town that supports adventurers, grows its economy, and survives escalating world-map threats.

## What v0.2.6 Adds

- Adventurers now have energy.
- World trips reduce adventurer energy.
- Returned adventurers check energy before leaving again.
- Low-energy adventurers walk to the Inn.
- Injured adventurers prioritize the Inn.
- Inn rest restores energy.
- Inn rest also restores HP.
- After resting, adventurers return to the General Store preparation loop.
- Adventurer labels now show HP and energy.

## Prototype Energy Values

```text
Max Energy: 100
Starting Energy: 100
Energy lost per world trip: 45
Low-energy threshold: 60
Inn rest restore: 100 energy
Inn HP recovery: full HP
```

## Updated Loop

```text
Spawn Adventurer
→ Buy Small Potion
→ Leave Town
→ World trip costs energy
→ Fight Slime
→ Return to Town
→ Re-enter as visible town adventurer
→ Sell Slime Gel
→ Check HP / energy
→ If injured or tired, go to Inn
→ Rest at Inn
→ Return to preparation loop
→ Buy potion if needed
→ Leave again if under max trip count
```

## Current Limitation

Inn rest is free and simplified. Later, Inn rest should generate income, require beds/rooms, take more realistic time, and connect to night-time behavior.
