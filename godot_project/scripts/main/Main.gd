extends Node2D

const DEBUG_UI_SCENE: PackedScene = preload("res://scenes/ui/DebugUI.tscn")

@onready var view_container: Node2D = $ViewContainer
@onready var ui_layer: CanvasLayer = $UILayer

var current_view: Node = null
var current_view_name: String = "None"

func _ready() -> void:
    SceneRouter.set_main(self)
    _spawn_debug_ui()
    SceneRouter.go_to_town()

func _spawn_debug_ui() -> void:
    var debug_ui := DEBUG_UI_SCENE.instantiate()
    ui_layer.add_child(debug_ui)

func load_view(scene_path: String, view_name: String) -> void:
    if current_view != null:
        current_view.queue_free()
        current_view = null

    var packed_scene := load(scene_path) as PackedScene
    if packed_scene == null:
        push_error("Could not load scene: " + scene_path)
        return

    current_view = packed_scene.instantiate()
    view_container.add_child(current_view)

    current_view_name = view_name
    GameState.current_view_name = view_name
    GameState.emit_state_changed()
