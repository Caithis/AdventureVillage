# Persistent Scene Architecture Notes

## Current Version

v0.2.3 implements the first persistent scene refactor.

## Design Goal

The Town map and World Map should both continue simulating while the player views either one.

Example:
- Player views World Map.
- Town adventurers still shop, rest, sell loot, and move around.
- Player views Town.
- World travelers still move, fight, return, and generate threats.

## Previous Architecture

Earlier versions used this pattern:

```text
Main
  ViewContainer
    CurrentView only
  UI Layer
```

Switching views did this:
1. Free current view.
2. Load requested scene.
3. Add requested scene as current view.

That was simple but caused a major design problem: the Town scene could not keep processing while the player viewed the World Map.

## v0.2.3 Architecture

Current pattern:

```text
Main
  ViewContainer
    Town
    WorldMap
  UI Layer
    DebugUI
```

Switching views now does this:
1. Keep both views loaded.
2. Show requested view.
3. Hide other views.
4. Update current view name.

## Why This Helps

This allows:
- Town adventurers to keep moving while the player views the World Map.
- World Map markers to keep updating while the player views Town.
- Less scene reset behavior.
- A cleaner path toward overlay-style maps and persistent simulation.

## Remaining Weakness

The game is still partly node-driven and partly data-driven.

Current split:
- Town adventurers are visible nodes.
- World travelers are dictionaries in GameState.
- Returned travelers are also dictionaries.

Future improvement:
- Create dedicated data records for adventurers.
- Create a TownSimulation manager.
- Create a WorldSimulation manager.
- Let scenes visualize persistent data instead of owning all behavior.

## Recommendation

Keep this persistent scene approach for now. Do not jump into a large architecture rewrite until after returned travelers can visibly re-enter town and sell loot.
