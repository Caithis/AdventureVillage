# Changelog

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
- Debug UI updates when town potion stock changes.

### Changed
- Adventurer AI now attempts a purchase at the General Store before going to the Town Exit.
- Adventurer wait-at-shop behavior now displays the purchase result state.

### Not Yet Added
- Shop UI.
- Item Resource-driven prices.
- World-map travel after exit.
- Combat.
- Threat clearing.
- Player building placement.

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
- Adventurer labels now update as the AI state changes.
- Town scene now passes marker positions into the adventurer routine.
- Future town-building design note added to project documentation.

## v0.1.1.1 - Autoload Name Conflict Hotfix

### Fixed
- Removed `class_name` from `GameClock.gd`.
- Removed `class_name` from `GameState.gd`.
- Removed `class_name` from `SceneRouter.gd`.
- Fixed Godot parser error where class names hid Autoload singleton names.

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
- Placeholder town and world-map views.
