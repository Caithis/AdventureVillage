extends Node

signal scene_changed(view_name: String)

const TOWN_VIEW_NAME := "Town"
const WORLD_MAP_VIEW_NAME := "World Map"

var main_scene: Node = null
var current_view_name: String = "Unknown"

func set_main(main: Node) -> void:
	main_scene = main

func go_to_town() -> void:
	_show_view(TOWN_VIEW_NAME)

func go_to_world_map() -> void:
	_show_view(WORLD_MAP_VIEW_NAME)

func request_spawn_adventurer() -> void:
	if main_scene == null:
		push_error("SceneRouter cannot spawn adventurer because no main scene is registered.")
		return

	if not main_scene.has_method("get_view_by_name"):
		push_error("Main scene does not expose get_view_by_name(view_name).")
		return

	var town_view: Node = main_scene.get_view_by_name(TOWN_VIEW_NAME)

	if town_view != null and town_view.has_method("spawn_placeholder_adventurer"):
		town_view.spawn_placeholder_adventurer()
	else:
		push_error("Could not spawn adventurer because the persistent Town view was not found.")

func _show_view(view_name: String) -> void:
	if main_scene == null:
		push_error("SceneRouter has no main scene registered.")
		return

	if not main_scene.has_method("show_view"):
		push_error("Registered main scene does not have a show_view(view_name) method.")
		return

	current_view_name = view_name
	main_scene.show_view(view_name)
	scene_changed.emit(view_name)
