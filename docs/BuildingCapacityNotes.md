# Building Capacity Foundation

## v0.4.5 Implementation

Buildings now have prototype capacity.

## Current Capacity Values

```text
General Store: 2
Inn: 2
```

## General Store Capacity

Adventurers use General Store capacity when:
- buying a potion
- selling Slime Gel

Capacity is released after the purchase/sale action finishes.

## Inn Capacity

Adventurers use Inn capacity when:
- resting
- sleeping at night

Normal rest releases capacity after the rest completes.

Night sleep holds the bed until day.

## Current Limitation

Capacity is currently tracked by building type:

```text
general_store
inn
```

It is not yet tracked by individual building instance.

This is enough for the first crowding prototype, but later we should track each placed building separately.

## Future Direction

Future capacity systems should include:
- per-building capacity
- building upgrades increasing capacity
- workers improving throughput
- waiting lines/queue positions
- service speed
- customer satisfaction
- UI capacity bars
- building click menu showing capacity details
