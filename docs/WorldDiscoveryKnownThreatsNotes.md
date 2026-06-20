# World Discovery / Known Threats Notes

## v0.6.20

This patch adds the first known-threats placeholder layer.

## Current Data

```text
known_monsters
known_nests
discovery_event_log
```

## Current Discoverable Threats

```text
Slime
Slime Nest
```

## Discovery Sources

Current placeholder sources:
- slime_sighted
- slime_defeated
- debug_discover

## Why This Matters

The future quest builder should not allow the player to target anything they have not discovered.

Discovery should eventually come from:
- adventurer exploration
- fog of war reveal
- scouting
- combat
- rumors
- Guild Hall upgrades
- dungeon/portal sightings

## Future Quest Builder Use

Known monsters and known nests should feed dropdown options such as:

```text
Hunt [known monster]
Cull [known nest]
Explore [known dungeon]
Scout [fogged zone]
```
