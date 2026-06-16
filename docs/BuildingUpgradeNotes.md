# Building Upgrade Foundation

## v0.5.1 Implementation

Placed buildings now have upgrade levels.

## Upgrade Level Range

```text
0 to 3
```

## Upgrade Cost Formula

```text
upgrade_cost = base_upgrade_cost × next_level
```

## Upgrade Effects

For service buildings:

```text
General Store:
    +1 capacity per level
    +10% service speed per level

Inn:
    +1 capacity per level
    +10% service speed per level
```

Guild Hall upgrades are allowed as a placeholder investment path, but major Guild Hall effects are planned for later.

## Save Data

Placed buildings now save:

```text
upgrade_level
```

## Current Limitations

- No upgrade construction time.
- No material requirements.
- No upgrade visuals yet.
- No upgrade confirmation prompt.
- Guild Hall upgrade effects are mostly placeholder.
- Upgrade balance is temporary.
