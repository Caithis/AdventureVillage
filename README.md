# Dungeon Frontier Guild-Town

Version: v0.5.2 - Building Detail Panel Polish

## What v0.5.2 Adds

This patch makes the building menu easier to read as building controls grow.

## Cleaner Building Menu Layout

The building menu is now organized into sections:

```text
IDENTITY
CAPACITY / QUEUE
SERVICE
WORKERS
UPGRADES
POLICY
```

This replaces the older stacked text/control approach that was becoming hard to scan.

## Better Fixed vs Placed Labels

The Identity section now clearly distinguishes:

```text
Placed building
Fixed fallback building
Protected test/safety building
```

Fixed fallback buildings should read as protected fallback buildings instead of looking like normal player-owned buildings.

## Cleaner Control Visibility

Unavailable controls are hidden more cleanly.

Examples:

```text
Guild Hall does not show worker controls yet.
Fixed fallback buildings do not show upgrade controls.
Non-service buildings show "not used yet" for capacity/queue/service sections.
General Store policy controls only show on General Store.
```

## Added Town Detail Helpers

Town now exposes cleaner building-detail helper methods for the UI:

```text
get_building_identity_summary()
get_building_capacity_queue_summary()
get_building_worker_summary()
get_building_placement_summary()
```

## Current Limitation

This is still a simple prototype panel, not the final UI.

Later this should become a proper styled building detail window with icons, tabs, compact spacing, and better pixel-art presentation.
