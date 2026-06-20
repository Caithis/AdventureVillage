# Building Management Popup Foundation Notes

## v0.6.15

This patch creates the first generic building-management popup foundation.

## Why This Matters

The sidebar is too narrow for complex building management.

Guild Hall, shops, crafting buildings, restaurants, and housing will all need richer controls.

## Current Popup Features

```text
solid background
X close button
scrollable content
building summary
building-specific content hook
```

## First Custom Building Screens

Implemented now:
- Guild Hall custom popup
- General Store placeholder popup
- Inn placeholder popup
- generic fallback popup

## Future Building Popup Needs

General Store:
- buy/sell toggles
- stock targets
- pricing
- material purchase policy
- adventurer purchase history

Potion Shop:
- potion recipes
- crafting queue
- ingredient stock
- potion sale policy

Weapon / Armor / Accessory Shops:
- crafting
- equipment stock
- item tiers
- adventurer purchase targeting

Restaurants:
- food tiers
- buff types
- pricing
- ingredient needs

Housing:
- resident assignment
- rent/upkeep
- happiness/satisfaction effects

## Design Warning

The popup foundation should grow incrementally.

Do not attempt every building system at once.
