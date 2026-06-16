# Dungeon Frontier Guild-Town

Version: v0.4.2 - Building Costs and Construction Rules

## What v0.4.2 Adds

This patch connects building placement to the economy.

## Building Costs

Current prototype costs:

```text
Guild Hall: 250g
Inn: 150g
General Store: 175g
```

When placing a new building:

```text
Village funds are checked.
If funds are too low, placement is blocked.
If funds are enough, funds are spent.
Floating -gold text appears.
```

## Demolish Refunds

Placed buildings now refund part of their cost when demolished.

Current prototype rule:

```text
Demolish refund: 50% of original cost
```

Fixed fallback buildings are still protected and cannot be demolished.

## Build Panel Feedback

The Build Mode panel now shows costs directly on the buttons:

```text
Build Guild Hall (250g)
Build Inn (150g)
Build General Store (175g)
```

The placement ghost also shows cost/validity feedback.

## Important Limitation

This is not a full construction system yet.

Still missing:
- build time
- workers/builders
- material costs
- confirmation prompts
- save/load
- placed buildings becoming adventurer destinations
