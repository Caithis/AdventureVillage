# Building Placement Foundation Notes

## v0.4.0 Implementation

This version adds the first player-facing build placement prototype.

## Current Buildable Buildings

```text
Guild Hall
Inn
General Store
```

## Current Placement Features

```text
Build Mode panel
Placeable ghost
Valid / invalid placement feedback
Grid snapping
Basic overlap checks
Buildable area check
Entrance / Exit clearance check
```

## Current Fallback Design

The original fixed buildings remain active.

Reason:
- The adventurer loop still depends on fixed marker positions.
- We do not want to break the working loop while adding placement.
- The next stage should gradually connect placed buildings to simulation targets.

## Current Limitation

Placed buildings:
- are not saved
- do not change adventurer destinations yet
- do not cost money yet
- do not require build time
- do not replace the fixed buildings yet

## Next Steps

Recommended next stages:
1. Building move / demolish.
2. Building cost.
3. Placed General Store becomes adventurer destination.
4. Placed Inn becomes rest destination.
5. Placed Guild Hall controls caps and policies.
6. Save/load building placements.
