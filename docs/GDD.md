# Dungeon Frontier Guild-Town

## Phase 0 Game Design Document

## 1. Working Title

**Dungeon Frontier Guild-Town**

Alternate title ideas:

* Guild Frontier
* Hearth & Hero
* Frontier Guildmaster
* Dungeonstead
* Adventurer’s Rest

## 2. High Concept

Dungeon Frontier Guild-Town is a 2D pixel-art management and simulation game where the player runs a frontier guild-town built near dangerous monster territory. Adventurers arrive in town, buy supplies, rest, sell loot, gain strength, explore the surrounding wilderness, and fight threats before they reach the town.

The player does not directly control adventurers like units in a strategy game. Instead, the player shapes the economy, infrastructure, incentives, notices, equipment supply, and town quality so adventurers naturally become stronger and more useful.

The core fantasy is:

**“Build the town that heroes depend on, then survive the dangers those heroes uncover.”**

## 3. Design Inspirations

This game is inspired by:

* Cozy pixel management games with small animated characters and town growth.
* Adventurer-town progression where heroes visit, shop, fight, and grow.
* Colony simulation concepts such as resource pressure, infrastructure, worker assignments, world threats, and emergent stories.
* World-map danger escalation where ignored threats eventually become direct attacks.

Important boundary:

This should be an original game. Do not copy protected art, names, UI, characters, exact mechanics, or proprietary assets from any existing game. Inspirations should guide feel and design direction only.

## 4. Target Engine

**Engine:** Godot 4.x
**Language:** GDScript
**Game Type:** 2D pixel-art simulation/management game
**Target Platform First:** Windows PC
**Input First:** Mouse and keyboard
**Art Workflow:** Placeholder sprites first, Aseprite refinement later

## 5. Visual Direction

The visual style should be cozy, readable, and compact.

### Character Sprite Direction

* 16x16 pixel character base sprites.
* Chibi-style proportions.
* Modular sprite layers when practical:

  * Base body
  * Hair
  * Hair color
  * Shirt/top
  * Pants/bottom
  * Shoes
  * Hat
  * Class accessory
  * Weapon overlay
* Initial version may use placeholder rectangles or simple sprites.
* Later versions should support Aseprite-made sprite sheets.

### Building Direction

Buildings should be compact, readable, and upgradeable.

Examples:

* Guild Hall
* Inn
* General Store
* Fletcher
* Armorer
* Weapon Shop
* Potion Shop
* Library
* Restaurant
* Stable
* Research building
* Housing

Each building should have a clear silhouette and level-up visual potential.

## 6. Core Player Role

The player is the guild-town manager.

The player:

* Builds town infrastructure.
* Upgrades buildings.
* Hires workers.
* Manages inventory and money.
* Produces goods from raw materials.
* Posts guild notices and quests.
* Encourages adventurers to handle threats.
* Contracts favorite adventurers into permanent resident heroes.
* Prevents monster threats from overwhelming the town.

The player should feel like they are managing the ecosystem that heroes need to survive.

## 7. Core Gameplay Loop

### Early Game Loop

1. Player starts with limited money.
2. Player builds an Inn and General Store.
3. Adventurers arrive in town.
4. Adventurers buy basic goods and rest.
5. Adventurers leave town to explore nearby zones.
6. Adventurers fight weak monsters.
7. Adventurers return with loot/materials.
8. Town buys materials from adventurers.
9. Player uses materials and money to build better shops.
10. Better shops produce better goods.
11. Better goods make adventurers stronger.
12. Stronger adventurers explore more dangerous zones.
13. More dangerous zones produce better rewards and bigger threats.

### Threat Loop

1. Monsters populate world-map zones.
2. Threats such as nests, portals, or dungeons appear.
3. Ignored threats grow over time.
4. Player posts notices to attract adventurers to threats.
5. Adventurers attempt to clear threats.
6. If threats are ignored too long, they create attacks against the town.
7. The player must maintain enough strong adventurers and infrastructure to survive.

### Emotional Loop

1. Adventurers visit as temporary travelers.
2. Some adventurers perform well or become memorable.
3. Player improves town services and happiness.
4. Happy adventurers can be contracted into resident heroes.
5. Resident heroes become long-term investments.
6. Player equips and sends favorite heroes to important threats.
7. The town develops a history around its best heroes.

## 8. Main Game Modes / Scenes

## 8.1 Town Scene

The Town Scene is where the player builds and manages infrastructure.

### Town Scene Features

* Build buildings.
* Upgrade buildings.
* Hire workers.
* Watch adventurers enter, shop, rest, and sell loot.
* Manage shops and production.
* Contract adventurers into residents.
* View town stats.
* Open Guild Hall notices.
* Switch to World Map.

### Early Town Buildings

#### Guild Hall

The town’s central progression building.

Controls:

* Adventurer visitor cap
* Resident hero cap
* Available notice types
* Threat management tools
* Town rank/progression

Example visitor cap progression:

* Level 1: 10 visitors
* Level 2: 20 visitors
* Level 3: 45 visitors
* Level 4: 70 visitors

These numbers are placeholders and should be adjusted during testing.

#### Inn

Provides rest to adventurers and generates early income.

Possible services:

* Restore health
* Improve happiness
* Generate rent/rest income
* Encourage adventurers to stay longer

#### General Store

The first economic building.

Functions:

* Sells starter items.
* Buys low-level materials.
* Helps establish the first money loop.

Starting goods:

* Small Potion
* Cheap Sword, later
* Basic supplies, later

Starting material:

* Slime Gel

## 8.2 World Map Scene

The World Map shows the dangerous frontier around town.

### World Map Features

* Zones around town.
* Fog of war.
* Adventurers or parties moving across the map.
* Monster populations.
* Threats such as nests, dungeons, and portals.
* Notices/quests placed by the player.
* Town attacks forming if threats grow too much.

### Zone Design

Zones should increase in danger farther from town.

Example:

* Zone 1: Grassland Edge
* Zone 2: Old Woods
* Zone 3: Broken Hills
* Zone 4: Sunken Ruins
* Zone 5: Demon Marches

Phase 1 only needs one zone.

### Fog of War

Fog of war prevents immediate danger escalation in unexplored regions.

Rule concept:
If a zone is still at least 50% covered by fog, it cannot generate a town attack yet.

This gives the player breathing room and creates a relationship between exploration and danger.

## 9. Adventurer Design

Adventurers are semi-autonomous agents.

They should feel alive without requiring direct micromanagement.

### Adventurer Properties

* Name
* Class
* Level
* Gold/budget
* Happiness
* Health
* Max health
* Attack
* Defense
* Speed
* Inventory
* Equipment
* Resident status
* Current goal
* Current location
* Relationship with town

### Starting Classes

Phase 1 only needs one class, but the intended starting class set is:

#### Fighter

* Durable melee class.
* Uses swords and armor.
* Good beginner adventurer.

#### Archer

* Ranged physical class.
* Uses bows.
* Faster but less durable.

#### Mage

* Magical class.
* Uses books/staves/magic items.
* Strong attacks but fragile.

### Adventurer Behavior

Adventurers should:

* Enter town.
* Choose needs.
* Visit stores.
* Buy useful items within budget.
* Rest when low health.
* Sell loot/materials.
* Leave town to explore.
* Prefer zones near their strength.
* Return when low on supplies, low health, or night approaches.
* Gain levels through combat.
* Increase budget as they earn money.
* Potentially leave town forever if not attached.
* Potentially become contractable if happy enough.

## 10. Resident Hero System

Most adventurers are temporary.

Some can become resident heroes.

### Resident Hero Requirements

An adventurer may become contractable if:

* Happiness is high enough.
* They have visited town enough times.
* They are not already committed elsewhere.
* The Guild Hall has available resident capacity.

### Resident Hero Benefits

Resident heroes:

* Stay associated with the town.
* Can be sent more reliably to threats.
* Can be equipped at reduced cost.
* Become long-term player investments.
* Create player attachment and emergent stories.

### Resident Hero Risks

Resident heroes should still be able to:

* Get injured.
* Fail quests.
* Require rest.
* Potentially die or retire in harder game modes.

Permanent death should not be considered for Phase 1.

## 11. Economy Design

The economy is built around adventurers and town production feeding each other.

### Basic Economy Flow

1. Adventurer buys supplies.
2. Adventurer fights monsters.
3. Adventurer gains loot/materials.
4. Adventurer sells materials to town.
5. Town uses materials to craft goods.
6. Goods are sold back to adventurers.
7. Adventurers become stronger.
8. Stronger adventurers bring better materials.

### Starting Resources

#### Money

The player starts with a small amount of money.

#### Slime Gel

Low-level material dropped by Slimes.

#### Small Potion

Starter consumable used to heal adventurers.

### Future Materials

* Wolf Pelt
* Goblin Scrap
* Iron Ore
* Mana Dust
* Spider Silk
* Bone Shards
* Drake Scale
* Ancient Relic Fragment

## 12. Building and Worker Design

Buildings are bought, placed, constructed, staffed, and upgraded.

### Building Level Rules

Building level affects:

* Worker capacity
* Production speed
* Inventory size
* Service quality
* Goods available
* Visual appearance

Example:

* Level 1 building: 1 worker
* Level 2 building: 2 workers
* Level 3 building: 3 workers

This rule is simple and should be kept early unless testing shows it needs more depth.

### Worker Types

Possible future worker types:

* Builder
* Shopkeeper
* Innkeeper
* Crafter
* Alchemist
* Cook
* Researcher
* Stablehand

Phase 1 should not implement full worker simulation yet.

## 13. Combat Design

Combat should be simple, readable, and simulation-friendly.

### Combat Model

* Each combatant has an action meter.
* The action meter fills based on speed.
* When full, the combatant acts.
* Adventurers attack enemies.
* Enemies attack adventurers.
* Adventurers use potions when health is low.
* Combat ends when one side reaches zero health.

### Starting Combat Entities

#### Adventurer

* One basic Fighter-like adventurer.

#### Slime

* Weak starting enemy.
* Drops Slime Gel.
* Teaches the basic combat/resource loop.

### Potion Rule

Adventurers can initially carry one potion.

If health drops below a threshold, they use the potion.

Example:

* Use Small Potion if health is below 40%.

Future research can increase potion capacity.

## 14. Threat Design

Threats are world-map problems that grow if ignored.

### Starting Threat

#### Slime Nest

A weak monster nest near town.

Behavior:

* Generates Slimes over time.
* Has a danger level.
* Can be targeted by a Guild Hall notice.
* Can be cleared by adventurers.
* If ignored long enough in later phases, can send Slimes toward town.

Phase 1 should show threat growth but does not need a full town attack yet.

### Future Threat Types

* Goblin Camp
* Spider Den
* Undead Crypt
* Bandit Hideout
* Mana Portal
* Demon Gate
* Ancient Dungeon
* Boss Lair

## 15. Guild Notice System

The Guild Hall allows the player to influence adventurer behavior.

### Notice Types

Phase 1:

* Clear Threat Notice

Future:

* Hunt Monsters
* Gather Materials
* Explore Fog
* Escort Caravan
* Defend Town
* Raid Dungeon
* Rescue Adventurer
* Boss Hunt

### Notice Behavior

A notice should:

* Target a world-map location or threat.
* Offer a reward.
* Attract suitable adventurers.
* Increase the chance that adventurers prioritize that objective.

The notice system should guide adventurers, not fully control them.

## 16. Time System

The game has a day/night cycle.

### Intended Full Timing

* Day: around 25 real-time minutes.
* Night: around 10 real-time minutes.

### Phase 1 Timing

Use much faster test timing.

Example:

* Day: 60 seconds.
* Night: 30 seconds.

The final timing should not be tuned until the core loop is playable.

### Night Behavior

At night:

* Adventurers become more cautious.
* Some adventurers return to town.
* Danger may increase.
* Monsters may become more active.

Phase 1 only needs day/night state changes.

## 17. Mount and Travel Progression

At higher levels, adventurers can move faster.

Concept:

* Adventurers gradually gain speed as they level.
* At level 25, adventurers can buy a mount from the Stable.
* Mounts noticeably improve world-map travel speed.

This is not part of Phase 1.

## 18. MVP Scope

The first playable MVP should include only:

* Main scene
* Town scene
* World map scene
* Game clock
* Basic money/inventory state
* One Guild Hall
* One Inn
* One General Store
* One adventurer
* One class
* One item: Small Potion
* One material: Slime Gel
* One enemy: Slime
* One threat: Slime Nest
* One zone
* One notice type
* Basic debug UI

## 19. Phase 0 Deliverables

Phase 0 is planning and setup only.

Deliverables:

* This GDD
* Project folder structure
* ProjectState.md
* Changelog.md
* KnownIssues.md
* ArtBible.md
* Initial Git repository
* Godot project created
* Naming conventions decided
* First milestone defined

## 20. Development Philosophy

Build the game in small patches.

Each patch should:

* Have one clear goal.
* Change a limited number of files.
* Include test steps.
* Update documentation.
* Avoid unnecessary rewrites.

Preferred development priority:

1. Make it work.
2. Make it understandable.
3. Make it expandable.
4. Make it pretty.
5. Make it balanced.

Do not chase perfect simulation early. The first goal is a working loop that proves the game is fun.
