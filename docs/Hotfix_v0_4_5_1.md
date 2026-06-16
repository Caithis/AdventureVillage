# Hotfix v0.4.5.1 - Store Capacity Release Timing and Inn Capacity

## Issue

General Store capacity stayed at `0/2` while adventurers were visibly entering and leaving the store.

## Cause

The adventurer AI requested General Store capacity correctly, but released it immediately after purchase/sale logic ran in the same action step.

That made capacity technically function for a very tiny moment, but it was too fast to see and did not meaningfully create waiting behavior.

## Fix

General Store capacity is now held through the visible result/wait state.

For buying:

```text
GoToGeneralStore
→ request capacity
→ BuySmallPotion
→ BoughtPotion / skip result wait
→ release capacity
→ GoToExit
```

For selling:

```text
GoToGeneralStoreToSell
→ request capacity
→ SellSlimeGel
→ SoldLoot / no-loot / sale-blocked result wait
→ release capacity
→ CheckRecoveryNeed
```

## Inn Capacity Change

Inn base capacity changed from:

```text
2 beds/rest slots
```

to:

```text
5 beds/rest slots
```

This better matches the early adventurer traffic level.
