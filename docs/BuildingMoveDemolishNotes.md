# Building Move / Demolish Notes

## v0.4.1 Implementation

Placed buildings can now be selected, moved, and demolished.

## Protected Buildings

Fixed fallback buildings are protected for now.

This prevents the current adventurer loop from breaking while the placement system is being built.

## Current Rules

```text
Placed building:
    can select
    can move
    can demolish

Fixed fallback building:
    can select
    cannot move
    cannot demolish
```

## Current Limitations

- No building costs yet.
- No refund on demolish.
- No save/load.
- Placed buildings are not simulation destinations yet.
- No confirmation prompt before demolish.
- No building inventory transfer.
- No construction time.

## Future Direction

Next steps:
1. Building placement costs.
2. Refunds or demolition penalties.
3. Build time.
4. Save/load placed building data.
5. Adventurers use placed General Store and Inn.
6. Guild Hall uses placed building for policies/caps.
