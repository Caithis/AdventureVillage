# Progress Roadmap - v0.6.08

## Current Focus

The current focus is still save/load architecture and UI safety.

This is important because the project now has:
- player-built town layout
- economy history
- adventurer identity data
- world state data
- multiple manual save slots

Without reliable saving, future systems will be painful to test.

## How Progress Feels

Progress is healthy, but we should not stay on save systems forever.

The save system is close to a good prototype stopping point.

## Near-Term Save Milestones

Remaining save-side work worth considering:
- autosave load option
- settings/main menu placeholder
- save/load QA pass
- save slot rename or thumbnails later, not urgent

## Next Gameplay Milestones To Return To

After save safety is stable, priority should shift back toward gameplay:

```text
1. Guild Hall management / adventurer cap clarity
2. Resident adventurer contract placeholder
3. Quest board / notice system foundation
4. Better adventurer goals and choices
5. Shop/Inn economy balancing
6. First dungeon/portal placeholder loop
7. Economy graph prototypes
```

## Watch-Out

Save systems are necessary, but they are not the core fun.

Once autosave and basic main-menu structure are in place, we should pivot back toward the player-facing gameplay loop.
