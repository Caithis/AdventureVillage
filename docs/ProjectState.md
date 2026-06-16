# Project State

## Current Version

v0.3.0 - Basic Building Economy Controls

## Current Working Systems

- Town and World Map remain loaded at the same time.
- Adventurers can buy potions, leave town, fight, return, sell loot, rest, sleep, and repeat.
- Village funds increase from potion sales and Inn use.
- Village funds decrease when buying materials from adventurers.
- Debug UI is scrollable and collapsible.
- Debug UI includes a Night Quest policy toggle.
- Debug UI includes a General Store Slime Gel buying toggle.
- General Store can be clicked.
- General Store has hover highlight feedback.
- General Store opens a prototype building menu.
- General Store building menu can toggle Slime Gel buying.
- If Slime Gel buying is off, returned adventurers cannot sell Slime Gel.
- If Slime Gel buying is off, village funds do not decrease from that sale.
- If Slime Gel buying is off, adventurer keeps Slime Gel.

## Not Included Yet

- Real building placement.
- Real building movement.
- Full building menu framework.
- Sliders for max stock / budget.
- Per-material menu list.
- Floating event text.
- Visible wandering monsters.
- Save/load.


## v0.3.1 Update Notes

Floating event text now appears for economy and world-map combat/travel events. This is a prototype and should later move to an event bus / floating text manager.


## v0.3.2 Update Notes

Visible Slime spawning is now active. Slimes spawn near the Slime Nest, wander, and can aggro nearby outbound travelers. Travelers target visible Slimes instead of only resolving invisible nest combat. An anti-swarm rule limits Slimes targeting one traveler.


## v0.3.3 Update Notes

Visible Slime combat now has a short contact delay, FightingVisibleSlime status, damage/event floating text, defeated Slime display delay, and a re-engagement cooldown. Adventurers may now hunt multiple Slimes during one outing until HP drops to the retreat threshold or the prototype kill cap is reached.


## v0.3.4 Update Notes

Slime Nest growth now meaningfully affects spawn pressure, monster stats, detection radius, movement speed, Slime Gel reward scaling, and raid pressure score/state. This is still a prototype foundation, not a final raid system.


## v0.3.5 Update Notes

Adventurers now have clearer flee behavior. Low-HP travelers stop hunting Slimes, clear their target, and flee toward town. Slimes can still chase weakened returners, but only with stricter fairness rules: reduced aggro radius, one chase per retreat, a flee grace timer, and a town safety radius.


## v0.4.0 Update Notes

The first town-building layer is now active. Town view has a Build Mode panel, a placement ghost, valid/invalid placement checks, basic grid snapping, and buttons for Guild Hall, Inn, and General Store placement. Fixed buildings remain as fallback and still drive the existing adventurer loop. Town Entrance and World Exit are now clearly marked.


## v0.4.1 Update Notes

Placed buildings can now be selected, moved, and demolished. Fixed fallback buildings remain protected so the existing adventurer loop is not broken while building placement becomes stable.


## v0.4.2 Update Notes

Building placement now affects village funds. Guild Hall, Inn, and General Store have placeholder costs. Placement is blocked if funds are too low. Demolishing placed buildings refunds 50% of original cost. Moving remains free for now.


## v0.4.3 Update Notes

Placed General Stores and Inns can now become active adventurer destinations. Dynamic route markers update after placement, movement, and demolition. Fixed fallback buildings are used only when no placed version exists. Build Mode panel is now collapsible to reduce screen clutter.


## v0.4.4 Update Notes

Placed buildings now save to `user://placed_buildings.json` and load when the Town scene starts. The system preserves building type, position, size, and original cost. Active route markers rebuild after load so placed General Stores and Inns can remain active destinations.


## v0.4.5 Update Notes

General Store and Inn now have prototype capacity. Adventurers request capacity before buying/selling/resting/sleeping and wait if the building is full. Active route labels show capacity usage. This patch also fixes the v0.4.4 issue where demolishing a loaded building did not always persist after reopening.


## v0.4.5.1 Hotfix Notes

General Store capacity now releases after the visible purchase/sale result wait instead of immediately. This makes occupancy visible and allows store-full waiting behavior to be observed. Inn base capacity increased from 2 to 5.


## v0.4.6 Update Notes

Building capacity now has visible queue slots. Waiting adventurers move to Store or Inn queue positions, route labels show queue counts, and occupied queue markers change color. Queueing is still type-level, not per-building-instance.


## v0.4.7 Update Notes

Placed buildings now receive unique instance IDs. Capacity and queue state now key off active building instance IDs instead of only building type. Route labels identify active building IDs. Queue fallback after demolition is fixed, and adventurers in travel/queue states retarget when route positions change.


## v0.4.8 Update Notes

Adventurer building routing now chooses per adventurer. Placed General Stores and Inns are preferred over fallback, nearest open buildings are preferred, and if all placed buildings are full the lowest-pressure building is selected. Route labels show routing mode, building count, open slots, and queue count.


## v0.4.9 Update Notes

Queue visuals are now attached to individual General Store and Inn buildings. Each service building shows local queue slots and local capacity/queue text on its label. This removes the previous single shared queue marker limitation.


## v0.5.0 Update Notes

General Store and Inn now have service time and worker placeholder counts. Worker placeholders affect service speed, labels show service time/worker count, and the building menu can adjust placeholder workers. Placed building worker counts are saved.


## v0.5.1 Update Notes

Placed buildings now have upgrade levels. General Store and Inn upgrades increase capacity and service speed. Upgrade levels save/load, and the building menu shows upgrade controls. Building instance IDs are intentionally unique and non-recycled; the save file stores only current buildings and the next ID counter.
