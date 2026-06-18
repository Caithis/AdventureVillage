# SaveManager Foundation

## v0.6.0 Implementation

Save/load is starting to move into one central autoload.

## New Autoload

```text
res://scripts/autoload/SaveManager.gd
```

Registered as:

```text
SaveManager
```

## Current Save Files

```text
user://placed_buildings.json
user://economy_history.json
user://save_index.json
```

## Current Responsibilities

SaveManager currently handles:
- generic JSON save
- generic JSON load
- building layout save/load file I/O
- economy history save/load file I/O
- save index creation
- future hook list

## Current System Ownership

Data ownership is still split:

```text
Town owns building layout data.
GameState owns economy data.
SaveManager owns file I/O.
```

This is intentional for the foundation.

## Future Direction

Later SaveManager should coordinate:
- full game save slots
- game settings
- adventurer data
- world map state
- town layout
- economy history
- quest/dungeon state
- monster nest state
- tutorial progression
