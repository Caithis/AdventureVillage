# Save Slot UI Foundation

## v0.6.4 Implementation

The Save sidebar now has a clearer Slot 1 interface.

## New UI Fields

```text
Save slot label
Last saved timestamp
Last loaded timestamp
Slot contents summary
Confirm overwrite placeholder
Clear slot placeholder
```

## Slot Contents Summary

The summary checks whether the manual Slot 1 files exist.

```text
Buildings
Economy
Adventurers
World
```

## Confirm Overwrite

Confirm overwrite is currently a placeholder toggle. It does not block Save All yet.

## Clear Slot

Clear Slot is currently a placeholder. It does not delete files yet.

## Why Clear Slot Is Not Destructive Yet

Deleting saves needs a proper confirmation flow. Until that exists, the button only confirms that clear-slot behavior has been requested.
