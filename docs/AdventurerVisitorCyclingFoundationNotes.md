# Adventurer Visitor Cycling Foundation

## v0.6.10

This patch starts the visitor population system.

## Design Goal

The town should not always have the same small group of adventurers forever.

Visitors should:
- arrive naturally
- adventure for several days
- leave the local region
- potentially return later
- become contract residents if they become favorites

## Current Prototype

The system currently tracks:

```text
visitor_id
visit_start_day
visit_days_limit
total_visits
departure_reason
visitor_pool
departed_visitor_history
active_regional_adventurer_cap
```

## Regional Cap

The cap counts both:

```text
in-town adventurers
world travelers
```

## Current Limitations

- Visitor spawning is still debug/manual.
- Resident contracts are not implemented yet.
- Happiness/satisfaction thresholds are not implemented yet.
- Cap scaling from Guild Hall/town level is not implemented yet.
- Two-trip dormant behavior still exists as temporary prototype logic.
