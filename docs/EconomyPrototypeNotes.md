# Economy Prototype Notes

## v0.2.8 Economy Values

### Adventurer Purchases

Small Potion:
- Adventurer pays: 15 gold.
- Town money increases by 15.
- Town Small Potion stock decreases by 1.
- Adventurer Small Potion inventory increases by 1.

### Adventurer Loot Sales

Slime Gel:
- Adventurer sells for 5 gold each.
- Town money decreases by 5 per Slime Gel.
- Town Slime Gel stock increases by the amount sold.
- Adventurer gold increases by 5 per Slime Gel.
- Adventurer inventory Slime Gel decreases to 0.

Example:
```text
2 Slime Gel x 5 gold = 10 gold
Town money: -10
Adventurer gold: +10
Town Slime Gel inventory: +2
```

### Inn Rest

Normal Inn rest:
- Fee: 8 gold.
- If adventurer can pay:
  - Adventurer gold decreases by 8.
  - Town money increases by 8.
  - HP restores to full.
  - Energy restores to full.
- If adventurer cannot pay:
  - Poor rest occurs.
  - Town money does not increase.
  - HP and energy recover only partially.

### Night Lodging

Night lodging:
- Fee: 5 gold.
- If adventurer can pay:
  - Adventurer gold decreases by 5.
  - Town money increases by 5.
  - HP restores to full.
  - Energy restores to full.
- If adventurer cannot pay:
  - Poor sleep occurs.
  - Town money does not increase.
  - HP and energy recover only partially.

## Future Debt / Loss Direction

Future goal:
- Town money may be allowed to go negative.
- If the town stays in debt too long, such as one week, the player risks losing.
- The player should have warning states before losing:
  - Solvent
  - Low Funds
  - In Debt
  - Critical Debt
  - Bankrupt / Game Over

## Future Building Purchase Controls

Future goal:
- Clicking a building opens a building menu.
- General Store can allow/disallow buying materials from adventurers.
- Individual materials can be toggled on/off.
- Later, sliders can control max stock or max budget per material.
