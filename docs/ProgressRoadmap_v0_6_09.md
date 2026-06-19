# Progress Roadmap - v0.6.09

## Current Focus

The current focus is save/load usability, menu structure, and UI separation.

This patch begins moving deeper game/system controls out of the sidebar and into an ESC menu overlay.

## How Progress Feels

Progress is steady and healthy.

The save system has reached a useful prototype level:
- manual slots
- autosave slot
- metadata
- overwrite/clear protection
- core/building/economy/adventurer/world save slices

We should not stay in save/menu work much longer.

## Recommended Near-Term Direction

One or two more UI infrastructure patches could be useful, but then we should return to gameplay.

Potential near-term infrastructure:
```text
v0.6.10 - Main Menu Save/Load Hook Placeholder
v0.6.11 - Sidebar Compact Button Pass
```

But I would not overdo it.

## Gameplay Systems To Return To

The most important next gameplay milestones:

```text
1. Guild Hall management / adventurer cap clarity
2. Visitor adventurer cycling foundation
3. Resident contract placeholder
4. Quest board / notice system foundation
5. Better adventurer goals and choices
6. Shop/Inn economy balancing
7. First dungeon/portal placeholder loop
8. Economy graph prototypes
```

## Production Warning

Save and UI systems are necessary, but they are support systems.

The core fun will come from:
- adventurers behaving believably
- the town economy responding to player layout/decisions
- world threats growing
- players choosing who to support/contract
- dungeon/portal pressure creating goals
