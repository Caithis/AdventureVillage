# Hotfix v0.1.1.1

## Issue Fixed

Godot reported parser errors such as:

`Class "GameClock" hides an autoload singleton.`

The same issue affected:
- `GameClock.gd`
- `GameState.gd`
- `SceneRouter.gd`

## Cause

The scripts used `class_name GameClock`, `class_name GameState`, and `class_name SceneRouter` while also being registered as Autoload singletons with those same names.

Godot treats both class names and Autoload singleton names as globally visible names, so this caused a namespace conflict.

## Fix

Removed `class_name` from the three Autoload scripts.

The Autoload names remain registered in `project.godot`:

```text
GameClock="*res://scripts/autoload/GameClock.gd"
GameState="*res://scripts/autoload/GameState.gd"
SceneRouter="*res://scripts/autoload/SceneRouter.gd"
```

Other scripts can still call:

```gdscript
GameClock
GameState
SceneRouter
```

because those names come from the Autoload singleton registration.
