# Main Menu Flow Design Notes

## Future Title Menu

The future game should start on a classic title/main menu:

```text
Continue
New
Load
Settings
Quit
```

## Continue

Continue should load the autosave slot.

Current intended autosave slot:

```text
autosave_1
```

## New

New should start a new save state.

Long-term, this may ask the player to choose a save slot or confirm overwriting an existing slot.

## Load

Load should open save slot selection.

Current manual slots:

```text
slot_1
slot_2
slot_3
```

## Settings

Settings should include:

```text
Graphics
Audio
Controls
Accessibility
Gameplay/UI preferences
```

## Quit

Quit should safely exit or return to desktop/title depending on context.
