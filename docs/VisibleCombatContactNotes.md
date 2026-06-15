# Visible Combat Contact Notes

## v0.3.3 Implementation

Combat now has a short visible contact state before resolving.

## Current Contact Flow

```text
Traveler touches Slime
→ Traveler status = FightingVisibleSlime
→ Slime status = Engaged
→ Contact delay starts
→ Combat resolves
```

## Current Contact Delay

```text
0.85 seconds
```

This is long enough to show that contact happened without making the prototype feel too slow.

## Current Cooldown

```text
1.5 seconds after combat
```

The cooldown helps stop instant chain engagements.

## Floating Text

Combat now produces:
- Combat!
- Victory!
- Defeated!
- Damage taken
- Slime Defeated
- Ambush!

## Future Direction

Later combat should move from instant resolution to:
- Visible attack timing
- Damage ticks
- Action meters
- Potion-use feedback
- Enemy defeat animation
- Adventurer flee behavior
