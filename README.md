# Dungeon Frontier Guild-Town

Version: v0.2.9 - Night Danger Scaling

## What v0.2.9 Adds

Night now matters on the world map.

### Night danger

At Night, Slimes become temporarily stronger during combat:

```text
Night Slime HP multiplier: 1.5x
Night Slime attack multiplier: 1.5x
```

This modifier is temporary. It is calculated at combat time and does not permanently mutate a spawned enemy.

### Night questing status

World travelers heading toward the Slime Nest during Night now show:

```text
NightQuesting
```

When Day returns, they return to normal travel status if they are still outbound.

### Low-energy retreat

Low-energy travelers may return to town instead of continuing toward danger at Night.

```text
Night retreat energy threshold: 40
```

### Night quest policy toggle

A debug toggle has been added:

```text
Toggle Night Quests
```

If Night Quests are disabled, outbound world travelers return to town at Night instead of continuing toward the Slime Nest.

This is a prototype stand-in for a future Guild Hall policy.

### Debug UI improvement

The Debug UI is now scrollable so it does not block as much of the game view as more labels and buttons are added.

## Future Systems Noted

This version also adds documentation for:
- Floating event text.
- Debug UI pages/collapsible sections.
- Visible wandering monsters around nests/dungeons.
- Monster spawn caps tied to nest growth.
- Future Guild Hall night quest policy controls.
