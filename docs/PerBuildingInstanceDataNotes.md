# Per-Building Instance Data Foundation

## v0.4.7 Implementation

Placed buildings now receive unique instance IDs.

## Example IDs

```text
general_store_001
inn_002
guild_hall_003
```

## Current Instance State

Capacity and queue dictionaries now key off active instance IDs.

This means state is no longer stored only under:

```text
general_store
inn
```

Instead it can be stored under:

```text
general_store_001
fallback_general_store
inn_002
fallback_inn
```

## Current Active-Building Rule

The newest placed building of a type is still treated as the active route destination.

This is not final.

Future options:
- nearest valid building
- player-selected active building
- distribute customers by capacity
- route by roads/path distance
- building priority toggle

## Dynamic Retargeting

When route markers update, adventurers in route or queue states receive updated destinations.

Currently retargeted states include:
- going to General Store
- waiting for General Store capacity
- going to Inn
- waiting for Inn capacity
- going to exit

Adventurers already inside service states may complete that service first.
