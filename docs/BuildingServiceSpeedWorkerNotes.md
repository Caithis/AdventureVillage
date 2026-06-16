# Building Service Speed / Workers Foundation

## v0.5.0 Implementation

Service buildings now calculate service time.

## Supported Building Types

```text
general_store
inn
```

## Base Service Times

```text
General Store: 1.75 seconds
Inn: 3.0 seconds
```

## Worker Placeholder Rule

```text
speed_multiplier = 1.0 + workers * 0.20
service_seconds = base_seconds / speed_multiplier
```

Worker count is currently capped at 3.

## Current Worker Controls

The building menu can add/remove placeholder workers for:
- General Store
- Inn

Placed building worker counts are saved.

## Current Limitations

This is not a real staffing system yet.

Missing:
- worker NPCs
- wages
- work schedules
- hiring UI
- worker skill
- worker happiness
- building staffing requirements
- service quality
- service failures
