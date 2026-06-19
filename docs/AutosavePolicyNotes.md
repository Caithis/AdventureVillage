# Autosave Policy Notes

## v0.6.09 Policy

Autosave should run at day boundaries, not after every individual action.

## Reason

The player should not be trapped by autosave immediately after a mistake.

Daily autosave creates a safety point while still allowing the player to recover from bad decisions.

## Current Trigger

```text
new_day_X
```

## Removed Triggers

Autosave no longer runs automatically after:

```text
building_placed
building_moved
building_demolished
building_upgraded
```

Manual Save All remains available for player-controlled snapshots.
