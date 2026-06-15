# Dungeon Frontier Guild-Town

Version: v0.2.5 - Basic Adventurer Loop Repeat

Dungeon Frontier Guild-Town is a Godot 4.x 2D pixel-art management/simulation project about running a frontier guild-town that supports adventurers, grows its economy, and survives escalating world-map threats.

## What v0.2.5 Adds

- After selling loot, returned adventurers can prepare for another trip.
- Returned adventurers wait briefly after `SoldLoot`.
- Returned adventurers check whether they need a Small Potion.
- Returned adventurers buy another Small Potion if available and affordable.
- Returned adventurers leave town again for another Slime Nest trip.
- A prototype max trip count prevents infinite loops.
- World-map `AwaitingTownReentry` markers are removed after the Town scene claims the returned traveler.

## Prototype Loop Limit

Current max trip count:

```text
2 trips per adventurer
```

This prevents the prototype from running forever while still proving that the repeat loop works.

## Updated Loop

```text
Spawn Adventurer
→ Buy Small Potion
→ Leave Town
→ Travel to Slime Nest
→ Fight Slime
→ Return to Town
→ Re-enter as visible town adventurer
→ Walk to General Store
→ Sell Slime Gel
→ Wait briefly
→ Check potion
→ Buy potion if needed/possible
→ Leave town again
→ Repeat until max trip count is reached
```

## Current Limitation

There is no Inn/rest/energy behavior yet. Exhaustion and night-time sleeping are planned design features, but this patch only proves loop repetition.

## Hotfix v0.2.5.1 Notice

This package includes a crash fix for returned travelers.

Fixed:
- Crash when a world traveler returned to town.
- Integer division warnings in `Town.gd`.
