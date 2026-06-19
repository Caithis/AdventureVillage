# World Map UI Compatibility Notes

## v0.6.09 Hotfix 3

The World Map now has its own right sidebar and ESC menu support.

## Why This Was Needed

Recent UI/save/debug work was mostly Town-focused.

The World Map still needed:
- return-to-town navigation
- debug controls
- save panel access
- ESC pause menu
- pause processing guard

## Current World Sidebar Tabs

```text
World
Save
Debug
```

## Integration Approach

The World Map does not duplicate town-building logic.

When Save All / Load All is triggered from the World Map, it retrieves the persistent Town view through `SceneRouter.main_scene.get_view_by_name()` and passes that to SaveManager.

This keeps full snapshots compatible with:
- buildings
- core state
- economy
- adventurers
- world state
