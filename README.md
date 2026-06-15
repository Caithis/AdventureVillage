# Dungeon Frontier Guild-Town

Version: v0.2.7 - Night Sleep Behavior

## What v0.2.7 Adds

- Adventurer behavior now checks the GameClock phase.
- Free/preparing adventurers seek the Inn during Night.
- Adventurers already committed to travel/quest flow continue.
- Night sleep restores HP and energy.
- Adventurers can wait at the Inn until Day returns.
- Recovery thresholds have been adjusted to reduce Inn overuse outside of night.

## Prototype Rest Thresholds

Outside of night sleep, adventurers now prefer the Inn only when:

```text
Health is at or below 50%
Energy is at or below 40%
```

Night sleep is separate:

```text
If it is Night and the adventurer is free/preparing, they seek the Inn to sleep.
```

## Updated Behavior

```text
Returned Adventurer
→ Sell Slime Gel
→ Check recovery need
→ If HP <= 50% or Energy <= 40%, rest at Inn
→ Else if Night, sleep at Inn
→ Else prepare for another trip
```

Adventurers already in the world continue their quest behavior for now.
