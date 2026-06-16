# Dungeon Frontier Guild-Town

Version: v0.4.1 - Building Move / Demolish Prototype

## What v0.4.1 Adds

This patch adds the first editable-building controls for placed buildings.

## Select Placed Buildings

Click a placed building to select it.

Selected buildings receive a clearer blue selection outline.

## Move Selected Building

Use:

```text
Move Selected
```

Rules:
- Only placed buildings can be moved.
- Fixed fallback buildings are protected.
- Moving uses the same valid/invalid placement ghost as normal building placement.
- Left-click confirms the new valid location.
- Right-click cancels the move and restores the building.

## Demolish Selected Building

Use:

```text
Demolish Selected
```

Rules:
- Only placed buildings can be demolished.
- Fixed fallback buildings are protected.
- No refund yet. Building costs/refunds are planned for a later economy patch.

## Fixed Fallback Protection

The original fixed Guild Hall, Inn, and General Store remain protected.

Reason:
- They still support the current adventurer loop.
- We should not delete or move them until placed buildings become simulation destinations.

## Current Limitation

Placed buildings are still not saved and still do not replace the fixed simulation buildings yet.
