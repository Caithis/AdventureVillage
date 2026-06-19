# Hotfix v0.6.07.1 - Save Slot Button Switching Fix

## Issue

Slot 2 and Slot 3 were visible but did not reliably become active when clicked.

## Fixes

- Reworked `SaveManager.set_active_slot()` so requested slot metadata is applied directly.
- Replaced lambda-style button connection with `bind(slot_number)`.
- Active slot buttons are no longer disabled.
- Asterisk remains the active slot indicator.
