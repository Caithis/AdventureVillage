# Floating Event Text Notes

## v0.3.1 Implementation

This version adds a simple reusable `FloatingText` scene.

Files:

```text
res://scenes/ui/FloatingText.tscn
res://scripts/ui/FloatingText.gd
```

## Current Behavior

Floating text:
- Appears at a Node2D position.
- Rises upward.
- Fades out.
- Deletes itself after a short lifetime.

## Current Event Sources

### Adventurer.gd

Used for:
- Potion purchases
- Slime Gel selling
- Sale blocked
- Inn rest payment
- Night lodging payment
- Poor rest / poor sleep
- Leaving town

### WorldMap.gd

Used for:
- Victory
- Defeat
- NightQuesting
- Night retreat
- Night quest policy retreat
- Day return after NightQuesting

## Future Direction

Floating text should eventually be event-driven.

Recommended later architecture:

```text
GameEventBus emits event
FloatingTextManager receives event
Manager decides where to show text
Scene spawns appropriate visual
```

Event examples:

```text
money_gained(amount, source_node)
money_lost(amount, source_node)
resource_gained(item_id, amount, source_node)
combat_victory(adventurer_id, monster_id)
combat_defeat(adventurer_id, monster_id)
sale_blocked(building_id, item_id)
```

## Future Improvements

- Color-code by event type.
- Add icons for gold/resources.
- Add damage/healing numbers.
- Prevent overlap with stacking offsets.
- Show building-related numbers above buildings instead of adventurers.
- Show enemy combat numbers over visible enemies once monsters exist.
