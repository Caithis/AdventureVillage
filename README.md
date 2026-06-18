# Dungeon Frontier Guild-Town

Version: v0.6.3 - World Traveler Save Data Foundation

## What v0.6.3 Adds

This patch starts saving world-side simulation state and fixes loaded town adventurers standing still.

## Fix: Loaded Adventurers Resume Movement

In v0.6.2, loaded adventurers restored their identity data but were set to `Idle`, so they stayed stationary with a save/load label.

Now loaded town adventurers resume a basic town routine after Load All.

They should display:

```text
Loaded. Resuming town routine.
```

Then move through the town loop again.

## World State Saved

Save All now includes:

```text
active world travelers
returned traveler records
visible slime state placeholder
slime nest growth/status
slime nest level
raid pressure summary
next world traveler/slime IDs
slime spawn timer
```

## New Save Files

Manual Slot 1 now writes:

```text
user://slot_1_building_layout.json
user://slot_1_economy_history.json
user://slot_1_adventurer_roster.json
user://slot_1_world_state.json
```

A live world-state path also exists for future use:

```text
user://world_state.json
```

## Visible Slime State Placeholder

Visible slime state now saves enough placeholder data to restore currently tracked slime dictionaries.

This is still not final ecological persistence. It is a first foundation.

## Save Sidebar Status

The Save sidebar now includes a World section showing:

```text
world travelers
returned records
visible slimes
slime nest status
nest level
growth
raid pressure
```

## Current Limitations

This is not full world simulation persistence yet.

Not yet saved perfectly:
- exact combat animation state
- future dungeon/portal state
- long-term zone discovery
- fog of war
- world events
- monster ecology history
