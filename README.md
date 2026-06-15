# Dungeon Frontier Guild-Town

Version: v0.3.1 - Floating Event Text Prototype

## What v0.3.1 Adds

This patch adds the first version of in-world event feedback.

Instead of relying only on labels and the Debug UI, important events now appear as floating text.

## Floating Text Events

### Town / Adventurer Events

Floating text now appears for:

```text
Potion purchases
Slime Gel sales
Sale blocked by General Store buying policy
Inn rest payment
Night lodging payment
Poor rest / poor sleep
Adventurer leaving town
```

### World Map Events

Floating text now appears above world traveler markers for:

```text
Victory
Defeat
Night retreat
Night quest restriction retreat
NightQuesting status
Day returned / night danger faded
```

## Why This Matters

This is the first step toward the kind of game feedback the final version needs:

```text
+15g above General Store / adventurer
-10g when town buys materials
+2 Slime Gel when resources are stocked
Victory! above traveler
Defeated! above traveler
Sale Blocked when a store refuses material
```

For now, most town-side text appears above the adventurer involved in the event. Later, we can route building-related text to the building itself.

## Current Limitation

Floating text is functional but not polished. It uses simple labels that rise and fade.

Future improvements:
- Color-coded positive/negative/resource/combat text
- Icons
- Pixel-art font styling
- Text above buildings, enemies, and world threats
- Event queue to avoid overlapping text

## Hotfix v0.3.1.1 Notice

This package fixes the launch-blocking `FloatingText.gd` parser error.

Fixed:
- `Cannot infer the type of "fade_ratio"`
- `FloatingText.gd` now uses explicit float typing with `clampf()`.
