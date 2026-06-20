# Quest Reward Spending Loop Notes

## v0.6.19

This patch checks whether quest rewards actually feed back into the town economy.

## Desired Loop

```text
Quest sponsor pays adventurer.
Adventurer carries quest reward gold.
Adventurer spends at town services.
Town earns through services, not direct quest payout.
```

## Why This Matters

Directly paying the town would bypass the management economy.

Paying adventurers creates stronger gameplay because services matter.

## Current Tracking

```text
quest_reward_gold
quest_reward_spent_in_town
quest_reward_spent_general_store
quest_reward_spent_inn
quest_reward_last_spend_message
```

## Future Budget Scaling

Adventurer budgets should eventually scale with:
- adventurer level
- town renown
- Guild Hall level
- dungeon depth reached
- previous quest success
- resident/visitor status
- personal wealth or class archetype

Higher-level adventurers should bring more money but demand better services.
