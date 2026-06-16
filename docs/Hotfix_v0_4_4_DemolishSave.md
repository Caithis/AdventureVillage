# v0.4.4 Demolish Save Fix Included in v0.4.5

## Issue

Demolishing a loaded building did not always persist after closing and reopening.

Moving saved correctly, but demolition could fail to remove the building from the saved file.

## Cause

The building was queued for deletion before saving, but it could still be present in the scene tree when the save list was collected.

## Fix

v0.4.5 removes the demolished building from its parent immediately before saving.

```gdscript
building_to_remove.get_parent().remove_child(building_to_remove)
building_to_remove.queue_free()
save_placed_buildings_to_file(false)
```

This ensures the save list no longer includes the demolished building.
