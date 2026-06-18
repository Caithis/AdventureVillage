# Full Game Save Button / Save Status UI

## v0.6.1 Implementation

The sidebar now exposes SaveManager through a Save mode.

## Sidebar Save Mode

Current buttons:

```text
Save All
Load All
```

## Current Save All Scope

```text
Building layout
Economy history
Save index
```

## Current Load All Scope

```text
Economy history
Building layout
```

## Save Slot Placeholder

The panel shows:

```text
Slot 1 (Prototype)
```

This is a UI placeholder only.

## Current Limitations

SaveManager does not yet save:
- adventurer state
- world map state
- monster/slime state
- active quests
- player settings
- tutorial state

Future versions should add those systems one at a time.
