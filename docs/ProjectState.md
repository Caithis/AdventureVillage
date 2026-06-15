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
