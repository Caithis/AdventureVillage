extends Node

signal scene_changed(view_name: String)

const TOWN_SCENE_PATH := "res://scenes/town/Town.tscn"
const WORLD_MAP_SCENE_PATH := "res://scenes/world_map/WorldMap.tscn"

var main_scene: Node = null
var current_view_name: String = "Unknown"

func set_main(main: Node) -> void:
	main_scene = main

func go_to_town() -> void:
	_go_to_scene(TOWN_SCENE_PATH, "Town")

func go_to_world_map() -> void:
	_go_to_scene(WORLD_MAP_SCENE_PATH, "World Map")

func request_spawn_adventurer() -> void:
	if main_scene == null:
		push_error("SceneRouter cannot spawn adventurer because no main scene is registered.")
		return

	if not main_scene.has_method("get_current_view"):
		push_error("Main scene does not expose get_current_view().")
		return

	var current_view: Node = main_scene.get_current_view()

	if current_view == null or not current_view.has_method("spawn_placeholder_adventurer"):
		go_to_town()
		current_view = main_scene.get_current_view()

	if current_view != null and current_view.has_method("spawn_placeholder_adventurer"):
		current_view.spawn_placeholder_adventurer()
	else:
		push_error("Could not spawn adventurer because the active view is not Town.")

func _go_to_scene(scene_path: String, view_name: String) -> void:
	if main_scene == null:
		push_error("SceneRouter has no main scene registered.")
		return

	if not main_scene.has_method("load_view"):
		push_error("Registered main scene does not have a load_view(scene_path, view_name) method.")
		return

	current_view_name = view_name
	main_scene.load_view(scene_path, view_name)
	scene_changed.emit(view_name)
