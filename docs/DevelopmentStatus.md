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


## v0.5.3 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 28%
Full intended game: about 18-20%
```

This patch is UI infrastructure polish. It does not add a major simulation system, but it makes the growing building systems usable and establishes the direction for a proper sidebar information layout.


## v0.5.4 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 29%
Full intended game: about 19-21%
```

This patch introduces the first shared sidebar UI foundation. It is an important structural step toward keeping the gameplay viewport readable while supporting deeper management menus.


## v0.5.5 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 30%
Full intended game: about 20-22%
```

This patch improves the sidebar layout and begins separating gameplay view space from UI space. That is important for future economy trends, debug tools, build tools, and management information.


## v0.5.6 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 31%
Full intended game: about 20-22%
```

This patch adds the first economy sidebar placeholder. It does not yet track real trends, but it reserves the UI space and data categories needed for future management feedback.


## v0.5.7 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 32%
Full intended game: about 21-23%
```

The project now has the first real economy event logging foundation. The next logical step is either saving economy history or showing clearer trend/history summaries over time.


## v0.5.8 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 33%
Full intended game: about 22-24%
```

The economy system now has basic time-bucketed data. This is still session-only, but it starts moving the project toward trend analysis instead of static totals.


## v0.5.9 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 34%
Full intended game: about 23-25%
```

The economy system now has persisted history and basic trend comparison. This is still not deep analytics, but it creates the foundation for charts, rolling averages, and per-building profitability later.


## v0.6.0 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 35%
Full intended game: about 24-26%
```

This is an architecture milestone. It does not add flashy gameplay, but it prevents save/load from becoming scattered as the project grows.


## v0.6.1 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 36%
Full intended game: about 24-27%
```

This patch makes the save architecture visible and testable. It is still not a complete full-game save, but it establishes the UI path for save slots and central save/load controls.


## v0.6.2 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 37%
Full intended game: about 25-28%
```

The save system now covers the first slice of adventurer persistence. This is intentionally identity/progression-first rather than exact AI-state restoration.


## v0.6.3 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 38%
Full intended game: about 26-29%
```

The save system now covers the first slice of world-state persistence. This is still not complete simulation restoration, but it is a meaningful foundation for future dungeons, monsters, and world events.


## v0.6.4 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 39%
Full intended game: about 27-30%
```

This patch improves save usability and readability. It is still a single-slot prototype, but the UI now gives clearer information about what the slot contains.


## v0.6.4 Hotfix 1 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 39%
Full intended game: about 27-30%
```

This hotfix improves save correctness by adding core state to the manual snapshot.


## v0.6.5 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 40%
Full intended game: about 28-31%
```

This patch improves save-slot reliability and moves the save UI toward a real multi-slot structure.


## v0.6.6 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 41%
Full intended game: about 29-32%
```

This patch makes save-slot destructive actions safer and moves the save system closer to player-facing reliability.


## v0.6.07 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 42%
Full intended game: about 30-33%
```

This patch makes the save system more usable by adding multiple manual slots. It is still a prototype save system, but it now behaves more like a real player-facing save interface.


## v0.6.08 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 43%
Full intended game: about 31-34%
```

The project is progressing well through infrastructure, but we should treat the save system as nearing a prototype stopping point. After autosave and perhaps a basic ESC menu foundation, we should pivot back toward gameplay systems such as Guild Hall management, adventurer contracts, quest notices, dungeons/portals, and economy graphs.


## v0.6.09 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 44%
Full intended game: about 32-35%
```

This patch improves interface structure and save policy. We are close to a point where save/menu infrastructure is good enough for now, and the project should pivot back toward gameplay systems: Guild Hall/adventurer cap, visitor cycling, resident contracts, quest notices, dungeon/portal loop, and economy graphs.


## v0.6.09 Hotfix 1 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 44%
Full intended game: about 32-35%
```

This hotfix improves UI clarity rather than adding new gameplay. The project should soon move back toward gameplay systems after the menu/sidebar foundation is stable.


## v0.6.09 Hotfix 2 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 44%
Full intended game: about 32-35%
```

This is UI/pause correction work. Once ESC/menu behavior is stable, we should return toward gameplay systems instead of staying in menu polish.


## v0.6.09 Hotfix 3 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 45%
Full intended game: about 33-36%
```

This is integration cleanup. The Town and World Map now share the same broad UI expectations, which means we can more safely return to gameplay systems next.


## v0.6.10 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 46%
Full intended game: about 34-37%
```

This patch moves us back into gameplay structure after UI/save integration. The visitor pool is still rough, but it starts turning adventurers into a rotating population rather than disposable test units.


## v0.6.10 Hotfix 1 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 46%
Full intended game: about 34-37%
```

This is a testing/recovery hotfix. It does not move gameplay forward, but it protects the next testing session from stale autosave and pause-state confusion.


## v0.6.10 Hotfix 2 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 46%
Full intended game: about 34-37%
```

This is an input routing correction caused by persistent scenes. It is important cleanup before continuing gameplay work.


## v0.6.11 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 47%
Full intended game: about 35-38%
```

This patch connects the visitor population loop back to a player-facing town building. That is a good gameplay-system step: the Guild Hall is starting to matter as a management structure instead of just being a placed object.


## v0.6.12 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 48%
Full intended game: about 36-39%
```

This patch improves testability and player feedback around visitor cycling. It also removes the worst effect of the temporary two-trip prototype by turning dormancy into region departure/re-entry. The system is still placeholder-heavy, but it is now easier to observe and iterate on.


## v0.6.13 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 49%
Full intended game: about 37-40%
```

This patch is a meaningful systems step because it starts turning transient visitors into remembered characters. The registry should not be overbuilt yet; its job is to prove that known adventurers can be tracked, favored, and prioritized before we add gifts/contracts.


## v0.6.14 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 50%
Full intended game: about 38-41%
```

This is a useful milestone: we now have a rough visitor-to-resident data path. My concern is that the Guild Hall UI is now clearly outgrowing the sidebar, so the next smart move is probably a targeted Guild Hall popup/refactor rather than adding more registry features into the cramped sidebar.


## v0.6.15 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 51%
Full intended game: about 39-42%
```

This is an important UI architecture step. The popup foundation gives us room to build deeper building management without overloading the sidebar. My recommendation after this test pass is to avoid more UI-only expansion unless there is a blocking issue; we should return to gameplay loops next.


## v0.6.16 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 53%
Full intended game: about 41-44%
```

This is an important gameplay-loop patch. It connects Guild Hall/world/combat/reward into one simple objective chain. The system is intentionally thin, but it gives adventurers a clearer reason to fight and gives the player a basic lever for regional activity.


## v0.6.17 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 54%
Full intended game: about 42-45%
```

This patch improves the economic logic of quests. Paying adventurers instead of the town is a stronger long-term direction because it makes quests feed the service economy rather than bypassing it.


## v0.6.18 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 55%
Full intended game: about 43-46%
```

This patch adds needed management tension. The player can now spend town money to influence adventurer behavior, but it is not free or absolute. That fits the game better than direct control.


## v0.6.19 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 56%
Full intended game: about 44-47%
```

This patch validates an important economy loop: outside quest money can enter through adventurers and later become town income through services. The long-term quest builder/world-map scope has also been captured so the current simple Slime Hunt does not become mistaken for the final quest design.


## v0.6.20 Status Update

Estimated progress:

```text
Prototype / vertical-slice foundation: about 57%
Full intended game: about 45-48%
```

This patch is a foundational world-map systems step. It does not add true fog of war yet, but it creates the data layer needed for discovered monsters, known nests, and future quest-builder dropdowns.
