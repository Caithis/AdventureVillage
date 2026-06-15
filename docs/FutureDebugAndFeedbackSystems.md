# Future Debug and Feedback Systems

## Debug UI Direction

The Debug UI is now scrollable as of v0.2.9.

Future improvements:
- Pages or tabs
- Collapsible/dropdown sections
- Separate sections for:
  - Town economy
  - Adventurers
  - World map
  - Threats
  - Cheats/testing buttons
  - Policies/toggles
- Smaller footprint while observing simulation
- Optional hide/show hotkey

## Floating Event Text

Future game feedback should include floating text above relevant objects.

Examples:

```text
+15g above General Store when potion is sold
-10g above General Store when Slime Gel is bought
+2 Slime Gel above General Store when materials are stocked
Victory! above adventurer or encounter
Defeated! above adventurer/enemy
-4 HP above adventurer during combat
+Energy above Inn after resting
```

## Why This Matters

The player should not have to read only the Debug UI to understand what happened.

Floating text gives immediate feedback:
- Money gained/lost
- Resources gained/lost
- Combat result
- Damage/healing
- Building activity
- Adventurer decision making

## Suggested Implementation Later

1. Create `FloatingText.gd`.
2. Add a simple FloatingText scene.
3. Add helper in Main/UI layer to spawn floating text.
4. Emit events from economy/combat actions.
5. Later replace debug-only floating text with polished UI feedback.
