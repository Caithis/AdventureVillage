# Building Instance ID Notes

## Why IDs Keep Increasing

Placed building IDs are unique and intentionally not reused.

Examples:

```text
general_store_001
general_store_002
general_store_003
```

If a building is demolished, its ID is not recycled.

This prevents bugs where old queue, occupant, route, or save references accidentally point to a new building.

## Is Extra Historical Data Being Stored?

No.

The save file stores:

```text
currently placed buildings
next_building_instance_number
```

It does not store every demolished building forever.

## What Happens After _999?

The ID formatter uses:

```gdscript
%03d
```

This means “at least three digits,” not “maximum three digits.”

So after:

```text
general_store_999
```

the next ID would be:

```text
general_store_1000
```

This is not a practical cap.

## Future Option

Later, once save/load is more mature, we may move from readable IDs to internal UUID-style IDs while keeping readable display names separate.
