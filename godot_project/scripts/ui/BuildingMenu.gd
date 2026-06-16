extends Control

@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var description_label: Label = $PanelContainer/VBoxContainer/DescriptionLabel
@onready var policy_label: Label = $PanelContainer/VBoxContainer/PolicyLabel
@onready var toggle_slime_gel_button: Button = $PanelContainer/VBoxContainer/ToggleSlimeGelButton
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

var current_building_id: String = ""
var current_building_node: Node = null
var current_town_node: Node = null

var service_label: Label = null
var add_worker_button: Button = null
var remove_worker_button: Button = null

func _ready() -> void:
	toggle_slime_gel_button.pressed.connect(_on_toggle_slime_gel_pressed)
	close_button.pressed.connect(_on_close_pressed)
	_create_service_controls()
	GameState.state_changed.connect(_refresh)

func _create_service_controls() -> void:
	var vbox := $PanelContainer/VBoxContainer

	service_label = Label.new()
	service_label.name = "ServiceLabel"
	service_label.text = "Service: -"
	service_label.visible = false
	vbox.add_child(service_label)
	vbox.move_child(service_label, close_button.get_index())

	add_worker_button = Button.new()
	add_worker_button.name = "AddWorkerButton"
	add_worker_button.text = "Add Worker Placeholder"
	add_worker_button.visible = false
	add_worker_button.pressed.connect(_on_add_worker_pressed)
	vbox.add_child(add_worker_button)
	vbox.move_child(add_worker_button, close_button.get_index())

	remove_worker_button = Button.new()
	remove_worker_button.name = "RemoveWorkerButton"
	remove_worker_button.text = "Remove Worker Placeholder"
	remove_worker_button.visible = false
	remove_worker_button.pressed.connect(_on_remove_worker_pressed)
	vbox.add_child(remove_worker_button)
	vbox.move_child(remove_worker_button, close_button.get_index())

func open_for_building(building_id: String, building_node: Node = null, town_node: Node = null) -> void:
	current_building_id = building_id
	current_building_node = building_node
	current_town_node = town_node
	visible = true
	_refresh()

func close() -> void:
	visible = false
	current_building_id = ""
	current_building_node = null
	current_town_node = null

func _refresh() -> void:
	var has_valid_building := current_building_node != null and is_instance_valid(current_building_node)
	var has_town := current_town_node != null and is_instance_valid(current_town_node)

	if current_building_id == "general_store":
		title_label.text = "General Store"
		description_label.text = "Controls what materials the General Store buys from adventurers."
		policy_label.text = "Slime Gel: " + GameState.get_general_store_buy_policy_text()
		toggle_slime_gel_button.visible = true
		toggle_slime_gel_button.text = "Toggle Slime Gel Buying (%s)" % GameState.get_general_store_buy_policy_text()
	elif current_building_id == "inn":
		title_label.text = "Inn"
		description_label.text = "Rest and lodging service building."
		policy_label.text = "Policy: rest/lodging enabled"
		toggle_slime_gel_button.visible = false
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

	var can_show_service: bool = has_town and has_valid_building and current_town_node.has_method("get_building_service_summary")
	if service_label != null:
		service_label.visible = can_show_service
		if can_show_service:
			service_label.text = current_town_node.get_building_service_summary(current_building_node)

	var can_adjust_workers: bool = has_town and has_valid_building and current_town_node.has_method("can_adjust_building_workers") and bool(current_town_node.can_adjust_building_workers(current_building_node))

	if add_worker_button != null:
		add_worker_button.visible = can_adjust_workers

	if remove_worker_button != null:
		remove_worker_button.visible = can_adjust_workers

func _on_toggle_slime_gel_pressed() -> void:
	if current_building_id == "general_store":
		GameState.toggle_general_store_buys_slime_gel()
		_refresh()

func _on_add_worker_pressed() -> void:
	if current_town_node != null and is_instance_valid(current_town_node) and current_town_node.has_method("adjust_building_worker_count"):
		current_town_node.adjust_building_worker_count(current_building_node, 1)
		_refresh()

func _on_remove_worker_pressed() -> void:
	if current_town_node != null and is_instance_valid(current_town_node) and current_town_node.has_method("adjust_building_worker_count"):
		current_town_node.adjust_building_worker_count(current_building_node, -1)
		_refresh()

func _on_close_pressed() -> void:
	close()
