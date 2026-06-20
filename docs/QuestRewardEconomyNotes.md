# Quest Reward Economy Notes

## v0.6.17

Quest rewards now go to adventurer wallets instead of village funds.

## Why This Is Better

The player manages the town, but adventurers complete the quest.

If rewards go directly to the town, the quest system becomes a generic town-income button.

If rewards go to adventurers, the economy loop is stronger:

```text
Quest sponsor pays adventurer.
Adventurer returns with money.
Adventurer buys goods/services.
Town earns through economy.
```

## Current Placeholder Source

Quest rewards are currently modeled as:

```text
external_commission_placeholder
```

This represents outside money entering the region through adventurers.

## Future Budget Question

Adventurer budgets need a dedicated design pass.

Likely future rules:
- visitors bring outside money when they enter/return
- higher-level adventurers bring larger budgets
- resident adventurers may have different income/spending patterns
- quest rewards increase spending capacity
- luxury services drain money from richer adventurers
- town economy should rely on useful services, not direct quest payouts

## Critical Warning

Do not let the economy become closed too early.

If adventurers only spend money already inside the town, the economy can stall.

The game needs controlled money faucets:
- visitors entering with money
- outside quest rewards
- kingdom/renown bonuses
- dungeon loot conversion
