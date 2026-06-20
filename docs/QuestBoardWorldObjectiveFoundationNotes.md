# Quest Board / World Objective Foundation Notes

## v0.6.16

This patch creates the first world objective loop.

## Current Placeholder Quest

```text
Title: Cull the Slimes
Target: Defeat 3 Slimes
Reward: 60 gold
Source: Guild Hall / Quest Board placeholder
```

## Current Flow

```text
Player posts quest.
Adventurers defeat Slimes on World Map.
GameState records progress.
Quest completes at target count.
Reward gold is paid.
Completed quest is logged.
```

## Why This Matters

The game needs reasons for adventurers to go into the world.

This system connects:
- Guild Hall
- adventurers
- World Map
- combat
- rewards
- player direction

## What Not To Add Yet

Do not immediately add:
- quest rarity
- many quest types
- quest chains
- quest failure states
- full assignment UI
- complex reward tables

The goal is one reliable gameplay loop first.
