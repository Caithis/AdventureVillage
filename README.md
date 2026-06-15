# Dungeon Frontier Guild-Town

Version: v0.3.3 - Visible Combat Contact Polish

## What v0.3.3 Adds

This patch makes visible world-map combat clearer and less abrupt.

## Combat Contact Delay

When a traveler and visible Slime touch, combat no longer resolves instantly.

Instead:

```text
Traveler contacts Slime
→ Traveler status becomes FightingVisibleSlime
→ Brief contact delay plays
→ Combat resolves
→ Floating result text appears
```

Current delay:

```text
Visible combat contact delay: 0.85 seconds
```

## Floating Combat Feedback

World-map combat now shows clearer floating feedback:

```text
Combat!
Victory!
Defeated!
-HP damage text
Slime Defeated
Ambush!
```

Slimes now remain visible briefly after defeat so the player can see the defeated text before the marker disappears.

## Combat Cooldown

After combat resolves, travelers receive a short re-engage cooldown.

```text
Combat re-engage cooldown: 1.5 seconds
```

This helps prevent an adventurer from instantly getting chained into another fight the moment combat ends.

## Multi-Monster Outing Prototype

Adventurers no longer have to fight exactly one Slime and immediately return.

Current behavior:

```text
Win against Slime
→ If HP is still safe and hunt cap is not reached, keep hunting
→ If HP is low or hunt cap is reached, return to town with loot
```

Prototype values:

```text
Retreat HP threshold: 50%
Max Slime kills per outing: 3
```

This is the first step toward adventurers actually acting like monster hunters.

## Weakened Retreat Danger

A weakened traveler returning home can still be chased by a nearby Slime.

Current fairness rules:

```text
Only weakened returning travelers can be chased.
Only 1 Slime can target one traveler at a time.
Combat cooldown prevents immediate chain fights.
```

This introduces danger during retreat without allowing full unfair swarms yet.
