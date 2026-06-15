# Changelog

## v0.3.2 - Visible Slime Spawn Prototype

### Added
- World Slime data records in GameState.
- Slime Nest active spawn count.
- Spawn interval tied to nest growth.
- Max active Slimes tied to nest growth.
- Visible Slime markers on World Map.
- Slime wandering near nest.
- Adventurers target visible Slimes.
- Travelers search near Slime Nest if no visible Slimes are active.
- Slime aggro onto nearby outbound travelers.
- Anti-swarm rule limiting Slimes targeting one traveler.
- Visible Slime spawn documentation.
- Combat fairness notes.

### Changed
- Slime Nest combat no longer immediately resolves against a fully invisible enemy when traveler reaches the nest.
- Traveler combat now references a visible Slime when one is available.
- Victory removes/deactivates the visible Slime involved.

### Not Yet Added
- Animated combat.
- Damage floating text.
- Visible enemy death animation.
- Full pathfinding.
- Monster XP and loot ownership.
- Parties or multi-adventurer combat.

## v0.3.1.1 - FloatingText Type Inference Hotfix

### Fixed
- Fixed FloatingText parser error.

## v0.3.1 - Floating Event Text Prototype

### Added
- Floating in-world event feedback.

## Earlier v0.3.x

- Building economy controls.
- Debug UI collapse fix.
