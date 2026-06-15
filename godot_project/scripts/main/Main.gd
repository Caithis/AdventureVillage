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
	_spawn_debug_ui()
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

func _spawn_debug_ui() -> void:
	var debug_ui := DEBUG_UI_SCENE.instantiate()
	ui_layer.add_child(debug_ui)

func show_view(view_name: String) -> void:
	if not views.has(view_name):
		push_error("Main does not have a persistent view named: " + view_name)
		return

	for existing_view_name in views.keys():
		var view: Node = views[existing_view_name]
		view.visible = existing_view_name == view_name

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
