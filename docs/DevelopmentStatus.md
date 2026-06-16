# Development Status

## Current Estimate

Overall project progress estimate:

```text
Prototype / vertical-slice foundation: about 12%
Full intended game: about 5-8%
```

This is still very early.

## What Exists

Currently implemented:
- Persistent Town and World Map scenes.
- Basic adventurer loop.
- Basic economy loop.
- Basic Inn rest/sleep.
- Basic night behavior.
- Visible Slime spawning.
- Visible combat contact prototype.
- Slime Nest growth pressure prototype.
- Clickable General Store prototype.
- Debug UI support.

## What Is Still Missing

Major systems still missing:
- Real building placement.
- Building movement.
- Town plot expansion.
- Roads/decorations.
- Guild Hall progression.
- Resident adventurers.
- Contracts/favorite heroes.
- Worker systems.
- Building upgrades.
- Better shop economy.
- Save/load.
- Real UI menus.
- Real art/animations.
- Multiple adventurer classes with actual differences.
- Multiple monster types.
- Multiple dungeons/nests/portals.
- Quests/notices.
- Threat clearing.
- Raids.
- Pathfinding.
- Balancing and progression.

## Important Terminology

When these notes say "polish" right now, it means:

```text
Prototype readability polish
```

It does not mean:

```text
Final game polish
```

The project is not in final polish. It is still in early systems prototyping.

## Near-Term Priority

The next stretch should focus on foundational gameplay systems:
1. Slime Nest pressure and raid foundation.
2. Adventurer retreat/flee behavior.
3. Building economy controls.
4. Building placement foundation.
5. Guild Hall actions/policies.
6. Save/load once data systems stabilize.


## v0.3.5 Status Update

Estimated progress remains early:

```text
Prototype / vertical-slice foundation: about 13%
Full intended game: about 6-8%
```

This patch improves survival/readability inside the prototype loop. It does not mean combat is final or polished. Major town-building and progression systems are still ahead.


## v0.4.0 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 15%
Full intended game: about 7-9%
```

This is the first real step into the town-building pillar. It is still disconnected from costs, build time, save/load, and adventurer destination logic.


## v0.4.1 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 16%
Full intended game: about 8-10%
```

The building pillar now has basic placement, selection, move, and demolish behavior, but it is still not connected to costs, save/load, or simulation routing.


## v0.4.2 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 17%
Full intended game: about 8-10%
```

The building pillar now has placement, movement, demolition, and basic money costs. It still needs construction time, save/load, material costs, and connection to adventurer routing.


## v0.4.3 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 18%
Full intended game: about 9-11%
```

The building pillar now affects adventurer routing for store and inn destinations. Still missing: capacity, save/load, building workers, upgrades, roads/pathfinding, and player selection of active buildings.


## v0.4.4 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 19%
Full intended game: about 10-12%
```

The building pillar now has a first save/load foundation. This is a key step, but the project still needs a full SaveManager for money, time, adventurers, world state, upgrades, and progression.
