# Dungeon Frontier Guild-Town

Version: v0.4.7 - Per-Building Instance Data Foundation

## What v0.4.7 Adds

This patch starts moving the building system away from shared building-type state and toward individual building instances.

## Unique Placed Building IDs

Placed buildings now receive unique instance IDs such as:

```text
general_store_001
inn_002
guild_hall_003
```

These IDs are shown on placed building labels and route labels.

## Per-Building Capacity State

Capacity and queue state now use the active building instance ID instead of only the building type.

Examples:

```text
general_store_001 has its own occupants and queue.
inn_002 has its own occupants and queue.
fallback_general_store has fallback state.
fallback_inn has fallback state.
```

This is still an active-building prototype, but it is now built on instance IDs instead of one shared type bucket.

## Route Labels Identify Active Building ID

Route labels now show:

```text
ACTIVE STORE
PLACED general_store_001
2/2 occupied | Q:1

ACTIVE INN
FALLBACK fallback_inn
0/5 occupied | Q:0
```

## Queue Fallback Bug Fixed

If you demolish a placed General Store or Inn, the queue markers should now return to the fallback building instead of jumping off-screen toward the map origin.

## First Dynamic Retargeting Fix

When a placed General Store or Inn is moved or demolished, adventurers currently traveling to that building should update their target if they are in a travel or queue state.

This is a first-pass fix. Adventurers already inside service states may still finish their current service before using the new route.
