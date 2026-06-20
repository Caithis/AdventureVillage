# Guild Registry Placeholder Notes

## v0.6.13

This patch creates the first visible known-adventurer registry.

## Current Registry Data

The registry currently reads from the visitor pool.

Each known adventurer can show:
- name
- visit count
- status
- last departure reason
- favorite placeholder flag
- priority return placeholder flag

## Placeholder Interaction

The buttons are intentionally simple:
- Toggle Favorite affects the first known adventurer.
- Mark Priority Return picks the best placeholder candidate.

This is not final UX.

## Future UX

Later, the registry should become an actual list where the player can select a specific adventurer.

Possible future actions:
- favorite/unfavorite selected adventurer
- send message/invitation
- pay resource cost to prioritize return
- give gifts
- review satisfaction/happiness
- offer resident contract

## Critical Scope Warning

This can become a big system quickly.

The right near-term goal is to keep it readable and testable, not feature-complete.
