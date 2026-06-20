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


## v0.5.2 Update Notes

The building detail menu now uses a cleaner sectioned layout with Identity, Capacity/Queue, Service, Workers, Upgrades, and Policy sections. Fixed fallback buildings are labeled more clearly and unavailable controls are hidden more cleanly.


## v0.5.3 Update Notes

The building detail panel now uses scrollable content and compact button rows so controls are not pushed off-screen. This patch also documents the future direction of a dedicated right-side sidebar for build/debug/building/economy menus while preserving the center gameplay viewport.


## v0.5.4 Update Notes

The Town scene now has a right sidebar container with mode buttons for Details, Build, and Debug. Building Details and Build Menu are docked into the sidebar, and only one sidebar mode is visible at a time. Debug is currently a placeholder while the existing debug overlay remains separate.


## v0.5.5 Update Notes

The project viewport is widened to create a right-side sidebar lane outside the original 1280-wide gameplay area. The Build Menu has been cleaned up for sidebar use with funds, placement instructions, compact buttons, and categories. The old Build Menu collapse behavior is hidden. Debug placeholder wrapping is fixed.


## v0.5.6 Update Notes

The sidebar now has an Economy mode with placeholder management data: current gold, income/outflow placeholders, and current stock snapshot. This prepares the UI for future economy event logging and trend displays. The duplicate Inn button declaration in the Build Menu was also removed.


## v0.5.7 Update Notes

Economy event logging now tracks session totals for shop sales, inn income, material purchase outflow, building construction spend, and upgrade spend. The Economy sidebar now displays real tracked totals and tracked net instead of placeholders.


## v0.5.8 Update Notes

Economy tracking now has current day buckets in addition to session totals. The Economy sidebar separates current day values from session totals and now uses scrollable content with Refresh/Reset buttons at the top.


## v0.5.9 Update Notes

Economy history now saves/loads from `user://economy_history.json`. The Economy sidebar shows current day, previous day, session totals, and simple current-vs-previous trend text. Manual Save History and Load History buttons were added for testing.


## v0.6.0 Update Notes

A new SaveManager autoload now owns shared JSON file I/O. Town still owns building layout data and GameState still owns economy data, but both systems now route save/load through SaveManager. Future save hooks are documented for adventurers, world state, and settings. Future economy graph goals are also documented.


## v0.6.1 Update Notes

The sidebar now includes a Save mode exposing SaveManager. Save All and Load All buttons were added, along with a save status display, last save/load result text, and a Slot 1 prototype placeholder. Save All currently covers building layout, economy history, and save index.


## v0.6.1 Hotfix 1 Update Notes

Save All / Load All now use separate manual Slot 1 snapshot files instead of the live auto-save files. This fixes the issue where demolishing or placing a building after Save All would overwrite the state that Load All was expected to restore.


## v0.6.2 Update Notes

Active town adventurers now export/import save data through SaveManager. Save All writes a manual Slot 1 adventurer roster snapshot and Load All restores saved active town adventurers as SavedInTown. The Save sidebar now shows adventurer save status, including active town count and visitor/resident placeholder counts.


## v0.6.3 Update Notes

SaveManager now includes a manual Slot 1 world state snapshot. GameState exports/imports active world travelers, returned traveler records, visible slime state placeholder data, and slime nest growth/status. Loaded town adventurers now resume a basic town routine instead of staying idle after Load All.


## v0.6.4 Update Notes

The Save sidebar now has a more explicit Slot 1 interface: slot label, last saved/loaded timestamp placeholders, slot contents summary, confirm overwrite placeholder, and clear slot placeholder. Save All / Load All behavior remains non-destructive and single-slot for now.


## v0.6.4 Hotfix 1 Update Notes

Save All / Load All now includes a core GameState snapshot for Village Funds, town inventory, and policy toggles. This fixes the issue where the debug panel gold did not reset after Load All. Loaded adventurers also avoid blindly resuming the sell-loot path if they have no Slime Gel.


## v0.6.5 Update Notes

Save slot metadata now persists in `user://save_slots_metadata.json`. Slot 1 now tracks occupied/empty state, last saved/loaded timestamps, save/load result text, and slot content summary across sessions. The metadata format is dictionary-based so future versions can add Slot 2/Slot 3 without rewriting the format.


## v0.6.6 Update Notes

Save slot overwrite and clear controls are now functional. Save All is blocked when Slot 1 is occupied unless overwrite is armed first. Clear Slot now requires two presses and deletes the manual Slot 1 snapshot files while leaving live/autosave files untouched. Slot metadata updates after clearing.


## v0.6.07 Update Notes

SaveManager now supports three manual save slots: Slot 1, Slot 2, and Slot 3. Save All, Load All, Clear Slot, and Arm Overwrite now target the active selected slot. Versioning also shifts to zero-padded incremental patch numbers starting at v0.6.07 to avoid symbolically approaching 1.0 too quickly during foundation work.


## v0.6.07 Hotfix 1 Update Notes

Slot 2 and Slot 3 button switching was fixed. SaveManager now applies requested active slot changes more directly, and Town's Save slot buttons use bound slot numbers instead of anonymous closures. The active slot is marked by an asterisk and buttons are not disabled.


## v0.6.08 Update Notes

Autosave now uses its own dedicated `autosave_1` slot and file paths, separate from manual save slots 1-3. Autosave runs after major safe events such as building placement, movement, demolition, upgrade, and new day start. The Save sidebar now displays autosave status. Future sidebar compaction and ESC main menu direction are documented.


## v0.6.09 Update Notes

ESC now opens a first main menu overlay with Resume, Save/Load, Settings, Graphics, Audio, Controls, and Quit placeholders. Autosave policy changed to daily-only to avoid trapping the player after individual mistakes. Main menu flow, sidebar UX direction, and adventurer population/cap cycling design are documented.


## v0.6.09 Hotfix 1 Update Notes

The old top-left Debug overlay is disabled and debug tools now live in the right sidebar Debug tab. ESC now opens a solid dark in-game pause menu with vertical Resume, Save/Load, Settings, and Quit buttons. Graphics/Audio/Controls are now Settings sections. Opening ESC pauses the simulation; closing it resumes. The future title/main menu is documented as a separate screen from the in-game ESC menu.


## v0.6.09 Hotfix 2 Update Notes

ESC pause now uses explicit GameState simulation pause plus tree pause. GameClock, Adventurer, AdventurerAI, and WorldMap processing now guard against simulation pause. ESC submenus are smaller, solid, scrollable, include an X close button, and Settings categories only appear under Settings-related panels.


## v0.6.09 Hotfix 3 Update Notes

The World Map now has compatible UI support: right sidebar, return-to-town navigation, world status, save/load panel access, debug tools, ESC pause menu, and pause guard in WorldMap processing. This clears important integration debt before returning to gameplay systems.


## v0.6.10 Update Notes

Added the first adventurer visitor cycling foundation: visitor pool, regional adventurer cap shared by Town/World Map, visitor visit limits, departure/re-entry placeholders, and visitor status in debug panels. Also fixed the ESC scene-switch bug by closing transient UI and clearing pause state before persistent view changes.


## v0.6.10 Hotfix 1 Update Notes

Added ClearAuto and ResetPause debug recovery buttons to both Town and World Map. ClearAuto uses a two-step confirmation and deletes only autosave_1 files. ResetPause force-clears ESC overlays, GameState simulation pause, and tree pause.


## v0.6.10 Hotfix 2 Update Notes

Fixed the Town ESC menu not appearing by preventing hidden persistent scenes from capturing input. Main now enables input/unhandled input only for the active visible persistent view, and Town/WorldMap guard ESC input by active scene.


## v0.6.11 Update Notes

Guild Hall now exposes regional adventurer cap and visitor intake controls. Regional cap is currently 3 plus the highest Guild Hall upgrade level as a placeholder. Visitor intake can be toggled through Guild Hall details or Debug tabs, and visitor spawning respects the intake policy.


## v0.6.12 Update Notes

Visitor cycling now has clearer feedback: floating text for blocked spawns, new registrations, returning visitors, and departures. A visitor event log placeholder tracks recent visitor events. Visitors who reach the current two-trip prototype limit now leave the local region with reason `debug_max_trips_complete` instead of staying dormant forever. Future Guild Hall registry, pool growth through renown, and priority return messaging are documented.


## v0.6.13 Update Notes

Added the first Guild Registry placeholder connected to the Guild Hall. Known adventurers are shown from the visitor pool with visit count, status, last departure reason, favorite placeholder, and priority return placeholder. Guild Hall details now include Toggle Favorite Placeholder and Mark Priority Return. Future polish note added for visitors walking to the village entrance before leaving.


## v0.6.14 Update Notes

Added first resident contract placeholder path. Favorite known adventurers can become contract candidates and be marked as resident_placeholder through Guild Hall details. Contracted residents request a house via house_request_status needs_house_placeholder and should not leave through visitor cycling. Added notes for future building detail popup UI, per-adventurer registry buttons, one-at-a-time priority return, and future house assignment.


## v0.6.15 Update Notes

Added generic Building Management Popup foundation. Clicking managed buildings now opens a larger main-screen popup with solid background, X close button, scrollable content, and building-specific sections. Guild Hall has the first custom popup with known adventurer registry rows and per-row Favorite, Request Return, and Contract buttons. General Store and Inn now have placeholder popup sections proving the system is not Guild-Hall-only. Sidebar Building Details remains fallback/debug.


## v0.6.15 Hotfix 1 Update Notes

Fixed Building Management Popup parse errors by adding safe popup helper wrappers for building type, capacity, service speed, and worker capacity. Corrected invalid ColorRect-to-string helper usage.


## v0.6.15 Hotfix 2 Update Notes

Fixed building management popup display path. Popup now lives in its own CanvasLayer, has explicit 1600x720 overlay sizing, is forced visible on open, and is deferred after sidebar/building detail refresh. Building type detection now reads the building_id script property.


## v0.6.15 Hotfix 3 Update Notes

Fixed popup not appearing by adding `_create_building_management_popup_overlay()` to the actual Town `_ready()` startup path. Added fallback creation in `_open_building_management_popup()` and duplicate CanvasLayer protection.


## v0.6.16 Update Notes

Added first Quest Board / World Objective foundation. A simple Slime Hunt quest can be posted from the Guild Hall popup or debug controls. Adventurers contribute to quest progress when they defeat Slimes. Quest completion pays a gold reward and stores a completed quest record. Quest status appears in Town debug, World Map info/debug, and Guild Hall popup.


## v0.6.17 Update Notes

Improved quest feedback and changed quest reward direction. Slime Hunt rewards now go to contributing adventurer wallets instead of directly to village funds. Reward distribution is based on contribution count, recorded in completed quest data, and tracked as external quest reward injection. Quest status now includes recent quest events and last feedback.


## v0.6.18 Update Notes

Added paid quest encouragement. The town can spend 35g through the Guild Hall popup or debug EncQ button to encourage adventurers toward the active Slime Hunt quest. Encouragement is influence, not direct control: it gives world travelers a movement/cooldown urgency boost and Quest Notice feedback, while tracking cost as quest_encouragement_outflow. Added notes about quest encouragement as a strategic budget decision rather than a free command.


## v0.6.19 Update Notes

Added Quest Reward Spending Loop tracking. Adventurers now track `quest_reward_gold` as a debug sub-wallet. When quest reward money is spent at the General Store or Inn, the economy records how much quest reward money flowed back into the town. Added docs for future adventurer budget scaling and the long-term ad-lib quest builder tied to fog of war, discovered monsters, nests, dungeons, and world-map regional management.


## v0.6.20 Update Notes

Added World Discovery / Known Threats placeholder. GameState now tracks known_monsters, known_nests, and discovery_event_log. Slime and Slime Nest can be discovered from sighting/spawn, defeat, or debug discovery. World Map, Town debug, and Guild Hall popup now show discovered threats. Added notes for future fog of war, zones, known dungeons, nest reduction, and ad-lib quest-builder dropdowns.
