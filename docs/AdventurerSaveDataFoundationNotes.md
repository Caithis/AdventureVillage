# Adventurer Save Data Foundation

## v0.6.2 Implementation

The game now saves active town adventurers into a roster snapshot.

## Save File

Manual Slot 1:

```text
user://slot_1_adventurer_roster.json
```

Future live path:

```text
user://adventurer_roster.json
```

## Data Owner

Current data ownership:

```text
Adventurer node owns individual adventurer data.
Town collects active town adventurer roster data.
SaveManager writes/loads snapshot files.
```

## Current Restore Behavior

When applying an adventurer roster snapshot:

```text
current active town adventurers are cleared
saved adventurers are respawned
identity/progression/inventory are restored
state label becomes SavedInTown
```

## Why Exact AI State Is Not Restored Yet

Exact AI state depends on:
- current target position
- building capacity reservations
- queue reservations
- active service timers
- world travel state
- combat state

Restoring that too early would create fragile bugs.

For now, this patch preserves identity/progression first.
