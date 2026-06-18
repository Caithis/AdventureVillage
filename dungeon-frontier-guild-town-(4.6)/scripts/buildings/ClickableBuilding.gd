extends ColorRect
class_name ClickableBuilding

signal building_clicked(building_id: String, building_node: Node)

@export var building_id: String = "building"
@export var normal_color: Color = Color(0.4, 0.4, 0.4, 1.0)
@export var hover_color: Color = Color(0.8, 0.72, 0.35, 1.0)

var highlight: ColorRect = null
var is_hovered: bool = false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    color = normal_color

    _set_existing_child_controls_to_ignore()

    highlight = ColorRect.new()
    highlight.name = "HoverHighlight"
    highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
    highlight.position = Vector2(-4, -4)
    highlight.size = size + Vector2(8, 8)
    highlight.color = Color(1.0, 0.95, 0.25, 0.32)
    highlight.visible = false
    add_child(highlight)
    move_child(highlight, 0)

    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    gui_input.connect(_on_gui_input)

func _set_existing_child_controls_to_ignore() -> void:
    for child in get_children():
        if child is Control:
            var control_child := child as Control
            control_child.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_mouse_entered() -> void:
    is_hovered = true
    color = hover_color

    if highlight != null:
        highlight.visible = true

func _on_mouse_exited() -> void:
    is_hovered = false
    color = normal_color

    if highlight != null:
        highlight.visible = false

func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mouse_event := event as InputEventMouseButton
        if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
            building_clicked.emit(building_id, self)
            accept_event()
