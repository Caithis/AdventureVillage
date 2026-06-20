extends Node2D

const DEBUG_UI_SCENE: PackedScene = preload("res://scenes/ui/DebugUI.tscn")
const TOWN_SCENE: PackedScene = preload("res://scenes/town/Town.tscn")
const WORLD_MAP_SCENE: PackedScene = preload("res://scenes/world_map/WorldMap.tscn")

@onready var view_container: Node2D = $ViewContainer
@onready var ui_layer: CanvasLayer = $UILayer

var views: Dictionary = {}
var current_view_name: String = "None"

func _ready() -> void:
    SceneRouter.set_main(self)
    _load_persistent_views()
    # Debug UI is now docked inside the Town sidebar instead of the old top-left overlay.
    SceneRouter.go_to_town()

func _load_persistent_views() -> void:
    var town_view := TOWN_SCENE.instantiate()
    town_view.name = "Town"
    view_container.add_child(town_view)
    views["Town"] = town_view

    var world_map_view := WORLD_MAP_SCENE.instantiate()
    world_map_view.name = "World Map"
    view_container.add_child(world_map_view)
    views["World Map"] = world_map_view

    for view in views.values():
        view.visible = false
        _set_view_input_enabled(view, false)

func _spawn_debug_ui() -> void:
    # Legacy top-left debug overlay disabled in v0.6.09 hotfix 1.
    # Debug tools now live in the right sidebar Debug tab.
    pass

func _set_view_input_enabled(view: Node, enabled: bool) -> void:
    if view == null:
        return

    view.set_process_input(enabled)
    view.set_process_unhandled_input(enabled)

func _close_transient_ui_before_view_switch() -> void:
    for view in views.values():
        if view != null and view.has_method("force_close_transient_ui"):
            view.force_close_transient_ui()

    if GameState.has_method("set_simulation_paused"):
        GameState.set_simulation_paused(false)

    if get_tree() != null:
        get_tree().paused = false

func show_view(view_name: String) -> void:
    if not views.has(view_name):
        push_error("Main does not have a persistent view named: " + view_name)
        return

    _close_transient_ui_before_view_switch()

    for existing_view_name in views.keys():
        var view: Node = views[existing_view_name]
        var is_active_view: bool = existing_view_name == view_name
        view.visible = is_active_view
        _set_view_input_enabled(view, is_active_view)

    current_view_name = view_name
    GameState.current_view_name = view_name
    GameState.emit_state_changed()

func load_view(_scene_path: String, view_name: String) -> void:
    # Backward-compatible wrapper for older SceneRouter calls.
    show_view(view_name)

func get_current_view() -> Node:
    return get_view_by_name(current_view_name)

func get_view_by_name(view_name: String) -> Node:
    if not views.has(view_name):
        return null

    return views[view_name]
