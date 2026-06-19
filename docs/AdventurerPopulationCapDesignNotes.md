# Adventurer Population and Cap Design Notes

## Long-Term Intent

The adventurer cap should represent adventurers currently active in the player's local region.

This includes adventurers in:

```text
village
world map
services
travel
quests
dungeons
```

## Natural Visitor Cycling

Adventurers should naturally visit the town, adventure for several days, then leave the region.

They are not permanently gone.

They can later return from the broader adventurer pool when space opens.

## Why Cycling Matters

The player should see many adventurers over time, not the exact same small group forever.

This keeps the town feeling alive and gives the player more personalities to notice.

## Resident / Contract Path

The player should be able to pick favorite adventurers and keep them long-term.

Possible flow:

```text
visitor uses town services
happiness/satisfaction rises
adventurer asks to live there
player offers contract/residency
adventurer becomes permanent resident
```

## Happiness vs Satisfaction

Either term can work.

Current recommendation:
- use `Satisfaction` for service/town approval
- use `Happiness` if we want a more personal emotional stat

This can be decided later.

## Cap Scaling

The active adventurer cap should increase through:

```text
Guild Hall level
or town level
```

This is still being workshopped.

## Current Prototype Limitation

Current adventurers have a temporary behavior where they only venture out twice before becoming dormant.

This is not final design.

That limit exists to prevent early prototype loops from running forever while systems are still unstable.


## Explicit Prototype Reminder

The current two-trip dormancy limit is temporary prototype logic and should not be treated as final adventurer behavior.
