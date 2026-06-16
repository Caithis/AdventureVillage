# Dungeon Frontier Guild-Town

Version: v0.5.0 - Building Service Speed / Workers Foundation

## What v0.5.0 Adds

This patch makes service buildings differ beyond location and capacity.

## Building Service Time

Current base service times:

```text
General Store: 1.75 seconds
Inn Rest: 3.0 seconds
```

These values are placeholders for testing.

## Worker Placeholder Effect

General Stores and Inns now have worker placeholder counts.

Current rule:

```text
Each worker adds +20% service speed.
Worker placeholders are capped at 3.
```

Example:

```text
0 workers: x1.00 speed
1 worker: x1.20 speed
2 workers: x1.40 speed
3 workers: x1.60 speed
```

Service time is calculated as:

```text
base service time / speed multiplier
```

## Building Labels Show Service Speed

Store and Inn labels now show:

```text
capacity / queue
service time
worker count
```

Example:

```text
General Store
general_store_001
1/2 Q:0
Svc:1.5s W:1
```

## Building Menu Worker Controls

Click a General Store or Inn to open the building menu.

The menu now shows service information and has placeholder worker controls:

```text
Add Worker Placeholder
Remove Worker Placeholder
```

For placed buildings, worker count is saved and loaded.

## Current Limitation

This is not a real worker hiring system yet.

Workers are placeholder values attached to buildings. There is no worker population, wages, schedule, skill, happiness, or staffing simulation yet.

## Hotfix v0.5.0.1 Notice

This package fixes the launch-blocking `BuildingMenu.gd` parser error from v0.5.0.

Fixed:
- Explicitly typed `can_show_service` as `bool`.
- Explicitly typed `can_adjust_workers` as `bool`.
- Wrapped the dynamic worker-adjustment method result with `bool(...)`.
