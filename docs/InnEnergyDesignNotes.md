# Inn and Energy Design Notes

## Purpose

This document records the intended future energy and Inn behavior.

This is not implemented in v0.2.5.

## Design Intention

Adventurers should not endlessly bounce between town and dungeon forever. Their behavior should be naturally regulated by exhaustion, injury, night-time, supplies, and comfort needs.

## Energy System

Future adventurers should have an energy value.

Energy should decrease from:
- Traveling
- Fighting
- Exploring
- Staying out at night
- Carrying loot, possibly later
- Repeated dungeon trips

Low energy should make adventurers more likely to:
- Return to town
- Visit the Inn
- Sleep/rest
- Delay their next trip

## Inn Behavior

The Inn should become a core support building.

Adventurers should use the Inn to:
- Restore energy
- Recover HP
- Sleep at night
- Improve happiness
- Possibly generate town income

## Night Behavior

At night:
- Most idle/free adventurers should seek the Inn to sleep.
- Adventurers already committed to a quest may continue.
- Adventurers in dangerous areas may attempt to return if low on supplies or energy.
- Night should increase danger and make resting more valuable.

## Implementation Recommendation

Add this after the repeat loop works:

v0.2.6:
- Add energy.
- Reduce energy after world trips.
- Returned adventurers choose Inn if energy is low.
- Inn restores energy.

Later:
- Link night phase from GameClock to AI decisions.
- Add sleeping behavior.
- Add Inn income.
