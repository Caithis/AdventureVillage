# Building Economy Controls

## v0.3.0 Implementation

The General Store now has the first material buying toggle.

Current control:

```text
General Store buys Slime Gel: On / Off
```

## Current Behavior

If buying is enabled:
- Adventurer can sell Slime Gel.
- Adventurer gains gold.
- Village funds decrease.
- Town Slime Gel stock increases.

If buying is disabled:
- Adventurer cannot sell Slime Gel.
- Adventurer keeps their Slime Gel.
- Village funds do not decrease.
- Adventurer receives a visible label message.

## Player Interaction

The General Store can be clicked to open a building menu.

The building menu currently includes:
- Building name
- Slime Gel buying status
- Toggle buying button
- Close button

## Hover Feedback

The General Store highlights when the cursor hovers over it.

This is the first pass at player-facing building interaction.

## Future Building Menu Direction

Later building menus should include:
- Stock levels
- Buying toggles by material
- Max stock sliders
- Daily budget sliders
- Worker assignment
- Prices
- Upgrade controls
- Move building button
- Building description and current effect
