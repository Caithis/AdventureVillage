# Dungeon Frontier Guild-Town

Version: v0.6.09 - ESC Main Menu Foundation

## What v0.6.09 Adds

This patch adds a first ESC main menu overlay and changes autosave policy.

## ESC Main Menu Overlay

Pressing ESC now opens/closes a main menu overlay.

Current buttons:

```text
Resume
Save / Load
Settings
Quit
Graphics
Audio
Controls
```

## Resume Button

Resume closes the overlay and returns to the current game.

## Save / Load Placeholder

The Save / Load tab currently shows:

```text
current manual slot summary
autosave status
future main menu flow notes
```

Actual Save All / Load All is still handled in the sidebar for now.

## Settings Placeholder

Settings has placeholder text for future:

```text
Graphics
Audio
Controls
Accessibility
Gameplay/UI preferences
```

## Graphics / Audio / Controls Placeholders

The overlay now has placeholder sections for:

```text
Graphics options
Audio options
Controls options
```

These are not functional settings yet.

## Autosave Policy Change

Autosave is now daily-only.

Autosave currently runs at the new-day boundary:

```text
new_day_X
```

Autosave no longer runs after every building placement, move, demolish, or upgrade.

## Why Autosave Changed

Autosave after every action can trap the player immediately after a bad decision.

Daily autosave gives safety without removing player recovery.

## Future Main Menu Design

Long-term title menu flow should be:

```text
Continue
New
Load
Settings
Quit
```

Design intent:

```text
Continue loads autosave.
New starts a new save state.
Load lets player pick a manual save slot.
Settings opens graphics/audio/control options.
Quit exits safely.
```

## Adventurer Population Reminder

The design notes now reiterate:

```text
Adventurers should cycle naturally through the village.
Visitors stay for several days, then leave the region.
Past visitors can return later from the adventurer pool.
Favorites can become permanent residents through happiness/satisfaction and contracts.
The cap includes both village and world-map adventurers.
The cap should scale with Guild Hall or town level.
The current two-trip dormancy behavior is temporary prototype logic.
```
