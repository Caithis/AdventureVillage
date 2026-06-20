# Visitor Feedback and Debug Departure Notes

## v0.6.12

This patch improves visibility for the visitor cycling system.

## Debug Departure Rule

For now, visitors leave the region after completing the current two-trip prototype limit.

Reason:

```text
debug_max_trips_complete
```

## Critical Design Note

This is not a good permanent rule.

It is a useful placeholder because it prevents dormant visitors from clogging the prototype.

Final visitor departure should likely account for:
- visit days
- satisfaction/happiness
- wounds/exhaustion
- contract/resident status
- adventurer goals
- town services
- world danger

## Visitor Events

The visitor log records:

```text
new_registration
returning_visitor
spawn_blocked
departure
```

## Guild Registry Future

Future development should add a Guild Hall registry of known adventurers.

Adventurers should register when first entering the Guild Hall/town region.

Later features could include:
- known adventurer list
- favorite/priority markers
- send message/invitation using resources
- priority return from visitor pool
- gifts or contracts to increase satisfaction
- resident adventurer conversion
