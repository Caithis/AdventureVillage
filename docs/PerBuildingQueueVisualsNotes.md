# Per-Building Queue Visuals

## v0.4.9 Implementation

Queue visuals are now attached to service buildings.

## Supported Building Types

```text
general_store
inn
```

## Visual Ownership

Each service building owns:

```text
LocalQueueVisuals
LocalQueueSlot_1
LocalQueueSlot_2
...
```

This replaces the earlier single shared queue marker system.

## Local Label Format

Placed buildings:

```text
Building Name
building_instance_id
occupied/capacity Q:queue
```

Fallback buildings:

```text
Building Name
(Fixed Test)
occupied/capacity Q:queue
```

## Current Limitations

The queue slots are still placeholder UI markers.

Future improvements should include:
- cleaner pixel-art queue slot sprites
- queue direction based on building entrance
- road/path-based queue positioning
- visible line movement
- service desk/counter positioning
- capacity shown in building menu
