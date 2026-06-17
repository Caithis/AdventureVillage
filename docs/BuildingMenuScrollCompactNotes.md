# Building Menu Scroll / Compact Mode

## v0.5.3 Implementation

The building detail panel now uses a scroll container.

## Layout

```text
PanelContainer
└── VBoxContainer
    ├── TitleLabel
    ├── DetailScroll
    │   └── DetailContentVBox
    │       ├── Identity
    │       ├── Placement
    │       ├── Capacity / Queue
    │       ├── Service
    │       ├── Workers
    │       ├── Worker buttons
    │       ├── Upgrades
    │       ├── Upgrade button
    │       ├── Policy
    │       └── Policy button
    └── Close button
```

The close button stays outside the scroll area.

## Why This Matters

The building menu now includes:
- identity
- placement state
- capacity
- queue
- service speed
- workers
- upgrades
- policy controls

Without scrolling, important controls can be pushed off-screen.
