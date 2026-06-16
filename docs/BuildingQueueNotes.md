# Building Queue Positions

## v0.4.6 Implementation

Buildings now have visible queue slots.

## Current Queue Markers

```text
Store queue: S1, S2, S3, S4, S5
Inn queue: I1, I2, I3, I4, I5, I6, I7
```

## Queue Flow

```text
Adventurer reaches full building
→ request queue slot
→ walk to queue slot
→ wait and retry capacity
→ when capacity opens, leave queue and use building
```

## Current Queue Label

Route labels now show:

```text
occupied/capacity | Q:waiting
```

## Current Limitation

Queue data is tracked by building type.

Later, it should be tracked per building instance so multiple Inns or General Stores can each have their own queue.

## Future Direction

Future queue systems should include:
- per-building queue ownership
- visible line movement
- service time
- workers affecting service speed
- queue patience
- adventurer happiness impact
- road/path bonus to queue flow
