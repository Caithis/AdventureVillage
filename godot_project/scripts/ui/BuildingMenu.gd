extends Control

@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var description_label: Label = $PanelContainer/VBoxContainer/DescriptionLabel
@onready var policy_label: Label = $PanelContainer/VBoxContainer/PolicyLabel
@onready var toggle_slime_gel_button: Button = $PanelContainer/VBoxContainer/ToggleSlimeGelButton
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

var current_building_id: String = ""

func _ready() -> void:
    toggle_slime_gel_button.pressed.connect(_on_toggle_slime_gel_pressed)
    close_button.pressed.connect(_on_close_pressed)
    GameState.state_changed.connect(_refresh)

func open_for_building(building_id: String) -> void:
    current_building_id = building_id
    visible = true
    _refresh()

func close() -> void:
    visible = false
    current_building_id = ""

func _refresh() -> void:
    if current_building_id == "general_store":
        title_label.text = "General Store"
        description_label.text = "Controls what materials the General Store buys from adventurers."
        policy_label.text = "Slime Gel: " + GameState.get_general_store_buy_policy_text()
        toggle_slime_gel_button.visible = true
        toggle_slime_gel_button.text = "Toggle Slime Gel Buying (%s)" % GameState.get_general_store_buy_policy_text()
    elif current_building_id == "":
        title_label.text = "Building"
        description_label.text = "Click a building to view controls."
        policy_label.text = "Policy: -"
        toggle_slime_gel_button.visible = false
    else:
        title_label.text = current_building_id.capitalize()
        description_label.text = "No controls available yet."
        policy_label.text = "Policy: -"
        toggle_slime_gel_button.visible = false

func _on_toggle_slime_gel_pressed() -> void:
    if current_building_id == "general_store":
        GameState.toggle_general_store_buys_slime_gel()
        _refresh()

func _on_close_pressed() -> void:
    close()
