# v0.6.6 Test Checklist

```text
[ ] Project opens in Godot 4.x.
[ ] Open Save sidebar.
[ ] If Slot 1 is occupied, press Save All.
[ ] Save All is blocked and warning appears.
[ ] Press Arm Overwrite.
[ ] Warning says overwrite is armed.
[ ] Press Save All.
[ ] Save succeeds and overwrites Slot 1.
[ ] Press Clear Slot once.
[ ] Warning says clear slot is armed.
[ ] Slot files still exist after first press.
[ ] Press Clear Slot again.
[ ] Slot 1 manual snapshot files are deleted.
[ ] Slot label changes to Empty.
[ ] Slot contents all show empty.
[ ] Last Saved resets.
[ ] Last Loaded resets.
[ ] Press Save All on empty slot.
[ ] Save succeeds without requiring overwrite.
[ ] Load All after clearing reports partial/no save instead of restoring old data.
[ ] Live/autosave files are not deleted by Clear Slot.
```
