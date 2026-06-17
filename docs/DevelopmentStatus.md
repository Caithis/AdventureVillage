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


## v0.4.5 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 20%
Full intended game: about 11-13%
```

The building pillar now has placement, movement, demolition, costs, save/load, routing, and first-pass capacity. It still needs per-building data, workers, upgrades, queues, and deeper UI.


## v0.4.6 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 21%
Full intended game: about 12-14%
```

The building pillar now has visible capacity pressure through queues. Next work should either deepen building instances or start adding workers/service speed.


## v0.4.7 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 22%
Full intended game: about 13-15%
```

The building system now has the beginning of per-instance data. The next major need is true multi-building routing so multiple stores/inns can serve different adventurers instead of only one active route target.


## v0.4.8 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 23%
Full intended game: about 14-16%
```

The building system now has first-pass multi-building routing. Next work should make per-building queues visible or add service speed/workers so different buildings feel meaningfully distinct.


## v0.4.9 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 24%
Full intended game: about 15-17%
```

The building system now has local queue visuals for individual service buildings. This makes multi-building routing easier to read and prepares the UI for building details, workers, and service speed.


## v0.5.0 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 25%
Full intended game: about 16-18%
```

The building system has crossed into a basic throughput model: buildings now have capacity, queues, routing, service time, and placeholder workers. The next major step is either real worker hiring or building upgrades.


## v0.5.1 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 26%
Full intended game: about 17-19%
```

The building system now supports investment through upgrades. Service buildings can improve capacity and service speed, and those improvements persist through save/load.


## v0.5.2 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 27%
Full intended game: about 17-19%
```

This patch improves usability rather than adding a large new simulation layer. That matters because building systems are now numerous enough that readable UI is becoming part of the core foundation.
