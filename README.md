# Dungeon Frontier Guild-Town

Version: v0.6.20 - World Discovery / Known Threats Placeholder

## What v0.6.20 Adds

This patch starts preparing the world map for the future ad-lib quest builder.

The guild now tracks discovered world threats.

## Current Discovery Data

GameState now tracks:

```text
known_monsters
known_nests
discovery_event_log
```

## Current Known Threats

For now, the only discoverable threat is:

```text
Monster: Slime
Nest: Slime Nest
```

Slime discovery can happen when:

```text
a Slime is sighted/spawned in the world
a Slime is defeated
debug discovery is pressed
```

## Known Nest Placeholder

The Slime Nest can now appear as a known nest with:

```text
nest level
growth
active monster count
raid pressure state
last discovery source
```

This is still placeholder data, but it prepares the game for future nest-reduction quest parameters.

## UI Additions

Known threats are now shown in:

```text
World Map sidebar/info
World Map debug
Town debug
Guild Hall building popup
Quest Board status text
```

## Debug Buttons

Town and World debug now include:

```text
DiscT
ResetT
```

`DiscT` discovers Slime and Slime Nest for testing.

`ResetT` clears known threat discovery data.

## Long-Term Quest Builder Direction

The current Slime Hunt quest remains temporary.

Future quest notices should be built from discovered information:

```text
Hunt [discovered monster] until [X killed]
Hunt [discovered monster] until [nest reduced to level Y]
Explore [known/active dungeon]
Scout [fogged zone]
```

The player should not be able to target threats the guild has not discovered.
