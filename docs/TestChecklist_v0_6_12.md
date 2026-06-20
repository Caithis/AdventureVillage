# v0.6.12 Test Checklist

```text
[ ] Project opens without blocking errors.
[ ] Spawn a visitor with intake open and cap space.
[ ] Floating text says new visitor registered.
[ ] Debug visitor log records new_registration.
[ ] Fill visitor cap.
[ ] Try spawning another visitor.
[ ] Floating text says spawn blocked.
[ ] Debug visitor log records spawn_blocked.
[ ] Let a visitor complete the current two-trip prototype allotment.
[ ] Visitor leaves instead of staying dormant forever.
[ ] Floating text shows visitor departure.
[ ] Debug shows departure reason debug_max_trips_complete.
[ ] Spawn again after departure opens cap space.
[ ] Returning visitor can appear from pool.
[ ] Floating text says returning visitor.
[ ] Debug visitor log records returning_visitor.
[ ] World Map debug shows visitor compact status.
[ ] World Map debug shows recent visitor log.
[ ] Save All / Load All preserves visitor event log.
```
