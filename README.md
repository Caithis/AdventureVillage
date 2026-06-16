# Dungeon Frontier Guild-Town

Version: v0.5.1 - Building Upgrade Foundation

## What v0.5.1 Adds

This patch lets placed buildings improve through investment.

## Upgrade Levels

Placed buildings now have upgrade levels:

```text
Lv 0 to Lv 3
```

Fixed fallback buildings cannot be upgraded.

## Upgrade Costs

Current prototype upgrade costs:

```text
General Store base upgrade cost: 125g
Inn base upgrade cost: 150g
Guild Hall base upgrade cost: 200g
```

Cost scales by next level:

```text
Lv 0 → Lv 1: base cost
Lv 1 → Lv 2: base cost × 2
Lv 2 → Lv 3: base cost × 3
```

## Upgrade Effects

For General Store and Inn:

```text
+1 capacity per upgrade level
+10% service speed per upgrade level
```

This means upgrades improve throughput beyond workers.

## Save / Load

Placed building upgrade levels are saved and loaded.

Saved building data now includes:

```text
building type
building instance ID
position
size
original cost
worker count
upgrade level
```

## Building Menu Upgrade Controls

The building menu now shows upgrade information and an upgrade button when a placed building can upgrade.

## Instance ID Note

Building IDs such as `general_store_001` are unique IDs, not a list of historical saves.

The save file stores only currently placed buildings plus the next ID counter. Demolished buildings are removed from the placed building list.

The `%03d` formatting means at least three digits, not a hard cap. After `_999`, the ID would become `_1000`.

## Hotfix v0.5.1.1 Notice

This package fixes the launch-blocking `Town.gd` parser error from v0.5.1.

Fixed:
- Explicitly typed upgrade capacity calculation values.
- Explicitly typed service-speed calculation values.
- Removed Godot's need to infer types from Dictionary `.get(...)` upgrade values.
