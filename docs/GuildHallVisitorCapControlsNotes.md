# Guild Hall Cap / Visitor Intake Controls

## v0.6.11

This patch makes the Guild Hall the first player-facing control point for the regional adventurer cap.

## Current Placeholder Rule

```text
Regional Cap = 3 + highest Guild Hall upgrade level
```

## Why Highest Guild Hall Level?

This avoids stacking multiple Guild Halls for unrealistic cap gains during the prototype.

Later we can decide if:
- only one Guild Hall is allowed
- multiple halls stack
- town level controls cap instead
- Guild Hall and town level both contribute

## Visitor Intake

Visitor intake can be toggled from:
- Guild Hall Building Details
- Town Debug tab
- World Map Debug tab

## Current Limitation

This is still not final residency or contract logic.

It only controls whether new visitors can enter the active regional pool.
