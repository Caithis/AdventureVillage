# Inn and Energy Design Notes

## v0.2.6 Implementation

This version introduces the first working energy and Inn rest prototype.

## Current Values

```text
Max Energy: 100
Starting Energy: 100
Energy lost per world trip: 45
Low-energy threshold: 60
Inn rest energy restore: full
Inn HP restore: full
```

## Current Behavior

1. Adventurer leaves town.
2. World traveler is created with current energy.
3. World trip reduces energy.
4. Traveler returns to town.
5. Returned adventurer checks HP and energy.
6. If energy is low or HP is below max, they walk to the Inn.
7. Resting restores HP and energy.
8. Adventurer returns to preparation behavior.

## Future Direction

The Inn should eventually:
- Generate lodging income.
- Have room capacity.
- Have quality/comfort ratings.
- Affect happiness.
- Affect whether adventurers want to become residents.
- Become the default night-time destination for free adventurers.

## Night Behavior Plan

At night:
- Idle/free adventurers should seek the Inn.
- Adventurers on active quests may continue.
- Exhausted adventurers should return if possible.
- Night danger may increase in frontier zones.
