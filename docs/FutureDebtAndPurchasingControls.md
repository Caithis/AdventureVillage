# Future Debt and Purchasing Controls

## Purpose

This document records future economy systems that are not fully implemented in v0.2.8.

## Debt / Loss Condition

Future goal:
- The town can go into negative money.
- Debt is allowed temporarily.
- If the player cannot recover from debt within a time limit, the town fails.

Prototype example:
```text
If town money is below 0 for 7 in-game days:
    trigger bankruptcy / game over
```

Possible warning stages:
```text
Solvent
Low Funds
In Debt
Critical Debt
Bankrupt
```

## Building-Level Purchase Controls

Future goal:
- Player clicks a building, such as the General Store.
- Building menu opens.
- Player can control what the building buys.

Examples:
```text
Buy Slime Gel: On/Off
Buy Wolf Fang: On/Off
Buy Iron Ore: On/Off
Max Slime Gel stock: slider
Daily material budget: slider
Emergency purchase stop: On/Off
```

## Why This Matters

Without purchase controls, the town may lose money buying materials the player does not want.

The player should be able to shape the economy:
- Stockpile materials
- Stop buying low-value items
- Reserve money for construction
- Avoid debt
- Focus on certain crafting chains

## Recommended Implementation Later

Do not implement full UI yet.

Suggested order:
1. Add data flags to building records.
2. Add debug toggles for buying Slime Gel.
3. Add simple building click menu.
4. Add per-material buy toggles.
5. Add max stock settings.
6. Add budget sliders.
