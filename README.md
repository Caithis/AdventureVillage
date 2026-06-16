# Dungeon Frontier Guild-Town

Version: v0.4.3 - Placed Building Destination Routing

## What v0.4.3 Adds

This patch starts connecting placed buildings to actual gameplay.

## Placed General Store Routing

If at least one placed General Store exists:

```text
Adventurers use the placed General Store as their shopping/selling destination.
```

If no placed General Store exists:

```text
Adventurers use the fixed fallback General Store.
```

## Placed Inn Routing

If at least one placed Inn exists:

```text
Returned or resting adventurers use the placed Inn as their rest/sleep destination.
```

If no placed Inn exists:

```text
Adventurers use the fixed fallback Inn.
```

## Dynamic Route Markers

The active route markers now update when buildings are:

```text
Placed
Moved
Demolished
```

The Town view now shows:

```text
ACTIVE STORE - PLACED / FALLBACK
ACTIVE INN - PLACED / FALLBACK
```

## Fixed Fallback Buildings

Fixed fallback buildings remain protected.

They are only used when no placed version of that building exists.

## Build Menu Collapsing

The Build Mode panel now has:

```text
Hide Build Menu
Show Build Menu
```

This is the first step toward keeping the build menu from cluttering the screen. A scrollable build menu is still planned once the construction list gets larger.
