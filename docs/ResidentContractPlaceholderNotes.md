# Resident Contract Placeholder Notes

## v0.6.14

This patch creates the first rough visitor-to-resident path.

## Current Contract Eligibility

A visitor can be a contract candidate when:

```text
known_to_guild = true
favorite_placeholder = true
total_visits >= 1
roster_role is not resident_placeholder
```

## Current Contract Result

Contracting sets:

```text
roster_role = resident_placeholder
status = resident_placeholder
contract_status = contracted_placeholder
resident_placeholder = true
house_request_status = needs_house_placeholder
assigned_house_id = ""
```

## House Request Design Note

Residents should eventually ask for housing.

The player should need to:
1. build a house
2. assign the resident
3. satisfy residency requirements

## Critical Design Note

Do not overbuild contracts until adventurers have more meaningful activities.

Resident contracts should matter because residents:
- stay in town/region
- grow stronger
- can be relied on
- consume housing/resources
- contribute to guild identity
