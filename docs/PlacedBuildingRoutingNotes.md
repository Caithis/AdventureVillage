# Placed Building Destination Routing Notes

## v0.4.3 Implementation

Placed buildings can now become active route destinations.

## Current Route Priority

For General Store:

```text
If placed General Store exists:
    use placed General Store
else:
    use fixed fallback General Store
```

For Inn:

```text
If placed Inn exists:
    use placed Inn
else:
    use fixed fallback Inn
```

## Multiple Placed Buildings

If multiple placed buildings of the same type exist, the newest one currently becomes the active route destination.

This is a prototype rule.

Future options:
- Let player choose active building.
- Route to nearest building.
- Route by stock/workers/capacity.
- Route by road/path distance.
- Route by building specialization.

## Dynamic Route Markers

The route markers update after:
- placement
- movement
- demolition

## Fixed Fallback Buildings

Fixed fallback buildings remain protected and serve as route fallback only.

They should not be removed until placed buildings fully support:
- save/load
- building capacity
- building economy
- adventurer routing
- upgrades/workers
