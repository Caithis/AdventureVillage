# ESC Pause Polish Notes

## v0.6.09 Hotfix 2

The ESC menu now uses both tree pause and explicit simulation pause state.

## Pause State

```text
get_tree().paused = true
GameState.simulation_paused = true
```

Systems that should stop now check:

```text
GameState.is_simulation_paused()
```

## Patched Systems

```text
GameClock
Adventurer
AdventurerAI
WorldMap
```

## Submenu Layout

ESC submenus now:
- fit inside 1600x720
- use a solid dark panel
- include an X close button
- use scrollable content
- only show Settings categories when appropriate

## Future Pause/Speed System

This is the first foundation for:
- pause
- normal speed
- fast speed
- possibly very fast speed
