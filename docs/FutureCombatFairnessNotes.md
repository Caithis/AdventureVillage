# Future Combat Fairness Notes

## Problem to Avoid

Visible monsters make the world feel alive, but they can become unfair if every monster immediately locks onto one adventurer.

Possible bad outcomes:
- One adventurer gets swarmed and dies unfairly.
- One strong adventurer hogs all kills and experience.
- Monsters constantly chain-aggro with no breathing room.
- Night becomes too punishing.

## Current Prototype Safeguard

v0.3.2 starts with:

```text
Max Slimes targeting one traveler: 1
```

This is a simple anti-swarm rule.

## Future Safeguards

Possible future systems:

```text
Aggro cooldown after combat
Max attackers based on adventurer party size
Adventurer flee behavior
Threat comparison before engaging
Monster leash radius
Monster return-to-nest behavior
Encounter reservation system
XP sharing by party/nearby adventurers
Guild Hall policy for dangerous/night quests
```

## Recommended Direction

Keep early combat readable and fair.

Add complexity slowly:
1. Visible monsters.
2. One-on-one aggro.
3. Combat delay.
4. Damage numbers.
5. Adventurer flee behavior.
6. Party combat.
7. Multiple attackers only when player expects that danger.
