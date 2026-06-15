# Project State

## Current Version

v0.2.9 - Night Danger Scaling

## Current Working Systems

- Town and World Map remain loaded at the same time.
- Adventurers can buy potions, leave town, fight, return, sell loot, rest, sleep, and repeat.
- Village funds increase from potion sales and Inn use.
- Village funds decrease when buying materials from adventurers.
- Debug UI is scrollable.
- Debug UI includes a Night Quest policy toggle.
- Night Quests can be enabled or disabled from Debug UI.
- World travelers can show NightQuesting status.
- Night combat temporarily strengthens Slimes.
- Low-energy outbound travelers can return to town at Night.
- Night Quest policy can force outbound travelers to return at Night.

## Current Night Rules

```text
If Night Quests disabled:
    Outbound traveler returns to town at Night.

If Night Quests enabled and traveler energy <= 40:
    Traveler returns to town at Night.

If Night Quests enabled and traveler energy > 40:
    Traveler continues as NightQuesting.
```

## Current Night Combat

```text
Slime HP x1.5
Slime attack x1.5
```

The modifier is temporary and only applies during Night combat.

## Not Included Yet

- Visible wandering monsters.
- Monster spawn caps.
- Floating event numbers.
- Guild Hall policy UI.
- Torches/supplies.
- Night raid pressure.
- Full pathfinding.
