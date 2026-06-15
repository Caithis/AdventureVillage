# Dungeon Frontier Guild-Town

Version: v0.2.4 - Returned Adventurer Re-entry

Dungeon Frontier Guild-Town is a Godot 4.x 2D pixel-art management/simulation project about running a frontier guild-town that supports adventurers, grows its economy, and survives escalating world-map threats.

## What v0.2.4 Adds

- Returned travelers now become visible town adventurers again.
- Returned adventurers spawn near the Town Exit.
- Returned adventurers walk to the General Store.
- Returned adventurers sell Slime Gel through a visible town routine.
- Automatic world-map Slime Gel sale has been removed.
- Town Slime Gel inventory increases during the visible General Store sale.
- Adventurer gold increases after selling Slime Gel.
- Returned adventurer label shows sale state and sale result.

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
→ Town gains Slime Gel
→ Adventurer gains gold
```

## Current Limitation

Returned adventurers sell loot and then idle at the General Store. They do not yet rest, shop again, leave for another trip, become residents, or despawn into a long-term data model.
