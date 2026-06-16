# Dungeon Frontier Guild-Town

Version: v0.4.5 - Building Capacity Foundation

## What v0.4.5 Adds

This patch makes placed buildings more than route targets.

## Building Capacity

Current prototype capacities:

```text
General Store: 2 customers
Inn: 2 beds/rest slots
```

## Adventurers Wait If Full

When an adventurer reaches a building:

```text
If capacity is available:
    Adventurer uses the building.

If capacity is full:
    Adventurer waits and retries.
```

New waiting messages include:

```text
General Store full. Waiting.
Store full. Waiting to sell.
Inn full. Waiting.
Inn full. Waiting for bed.
```

## Route Labels Show Capacity

Active route labels now show occupancy:

```text
ACTIVE STORE
PLACED / FALLBACK
0/2 occupied

ACTIVE INN
PLACED / FALLBACK
0/2 occupied
```

## Demolish Auto-Save Fix

This patch also fixes the v0.4.4 issue where demolishing a loaded building did not always save correctly.

The fix removes the demolished building from the scene tree before saving the building list.

## Important Limitation

Capacity is currently tracked by building type, not by individual building instance.

That means if multiple General Stores exist, the current active General Store uses the shared General Store capacity. Later versions should support per-building capacity.

## Hotfix v0.4.5.1 Notice

This package fixes General Store capacity releasing too quickly.

Fixed:
- Store capacity should now visibly increase while adventurers are buying/selling.
- Store capacity releases after the result wait state instead of immediately.
- Waiting behavior should now be easier to trigger when many adventurers reach the store.
- Inn base capacity increased from 2 to 5.
