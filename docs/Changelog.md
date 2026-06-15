# Changelog

## v0.1.4 - World Travel Placeholder

### Added
- `world_travelers` tracking in `GameState`.
- World traveler count in Debug UI.
- World traveler data creation when an adventurer leaves town.
- Placeholder world traveler markers on World Map.
- `LeavingTown` adventurer AI state.
- Adventurer cleanup after reaching Town Exit.
- Controlled General Store queue target offsets.

### Fixed
- Successful Small Potion purchases now add 15 gold to the town treasury.
- Adventurers no longer use large spawn offsets as shop stopping offsets.
- General Store stopping points should now be more controlled and less likely to appear past the building.

### Not Yet Added
- World traveler movement.
- Slime Nest targeting.
- Combat.
- Loot return.
- Save/load.
- Player building placement.

## v0.1.3 - Small Potion Purchase

### Added
- Small Potion purchase logic.
- Small Potion test price set to 15 gold.
- Adventurer purchase states:
  - `BuySmallPotion`
  - `BoughtPotion`
  - `SkipPurchaseNoStock`
  - `SkipPurchaseNoGold`
- Adventurer checks town Small Potion stock before buying.
- Adventurer checks personal gold before buying.
- Adventurer loses gold after a successful purchase.
- Town Small Potion stock decreases after a successful purchase.
- Adventurer inventory gains `small_potion` after a successful purchase.
- Adventurer label now displays carried potion count.

## v0.1.2 - Adventurer Town Routine

### Added
- Marker-based movement for placeholder adventurers.
- Basic movement speed on `Adventurer.gd`.
- Adventurer AI state flow:
  - `EnterTown`
  - `GoToGeneralStore`
  - `WaitAtGeneralStore`
  - `GoToExit`
  - `IdleAtExit`

## v0.1.1.1 - Autoload Name Conflict Hotfix

### Fixed
- Removed `class_name` from `GameClock.gd`.
- Removed `class_name` from `GameState.gd`.
- Removed `class_name` from `SceneRouter.gd`.

## v0.1.1 - Placeholder Adventurer Spawn

### Added
- `Adventurer.tscn`.
- `Adventurer.gd`.
- `AdventurerAI.gd`.
- Enabled Spawn Adventurer button in Debug UI.
- Town scene can spawn placeholder adventurers.
- Adventurers register with GameState.

## v0.1.0 - Walking Skeleton

### Added
- Main scene.
- Town scene.
- World Map scene.
- Debug UI scene.
- GameClock autoload.
- GameState autoload.
- SceneRouter autoload.
- Scene switching.
