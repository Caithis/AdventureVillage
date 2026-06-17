extends Control

@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var description_label: Label = $PanelContainer/VBoxContainer/DescriptionLabel
@onready var policy_label: Label = $PanelContainer/VBoxContainer/PolicyLabel
@onready var toggle_slime_gel_button: Button = $PanelContainer/VBoxContainer/ToggleSlimeGelButton
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

var current_building_id: String = ""
var current_building_node: Node = null
var current_town_node: Node = null

var identity_section_label: Label = null
var capacity_section_label: Label = null
var service_section_label: Label = null
var worker_section_label: Label = null
var upgrade_section_label: Label = null
var policy_section_label: Label = null

var add_worker_button: Button = null
var remove_worker_button: Button = null
var upgrade_button: Button = null

func _ready() -> void:
	toggle_slime_gel_button.pressed.connect(_on_toggle_slime_gel_pressed)
	close_button.pressed.connect(_on_close_pressed)
	_create_detail_panel_layout()
	GameState.state_changed.connect(_refresh)
	visible = false

func _create_detail_panel_layout() -> void:
	var vbox := $PanelContainer/VBoxContainer

	description_label.visible = false
	policy_label.visible = false
	toggle_slime_gel_button.visible = false

	identity_section_label = _create_section_label("IdentitySectionLabel")
	vbox.add_child(identity_section_label)
	vbox.move_child(identity_section_label, close_button.get_index())

	capacity_section_label = _create_section_label("CapacitySectionLabel")
	vbox.add_child(capacity_section_label)
	vbox.move_child(capacity_section_label, close_button.get_index())

	service_section_label = _create_section_label("ServiceSectionLabel")
	vbox.add_child(service_section_label)
	vbox.move_child(service_section_label, close_button.get_index())

	worker_section_label = _create_section_label("WorkerSectionLabel")
	vbox.add_child(worker_section_label)
	vbox.move_child(worker_section_label, close_button.get_index())

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

	upgrade_section_label = _create_section_label("UpgradeSectionLabel")
	vbox.add_child(upgrade_section_label)
	vbox.move_child(upgrade_section_label, close_button.get_index())

	upgrade_button = Button.new()
	upgrade_button.name = "UpgradeButton"
	upgrade_button.text = "Upgrade Building"
	upgrade_button.visible = false
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	vbox.add_child(upgrade_button)
	vbox.move_child(upgrade_button, close_button.get_index())

	policy_section_label = _create_section_label("PolicySectionLabel")
	vbox.add_child(policy_section_label)
	vbox.move_child(policy_section_label, close_button.get_index())

	vbox.move_child(toggle_slime_gel_button, close_button.get_index())

func _create_section_label(label_name: String) -> Label:
	var label := Label.new()
	label.name = label_name
	label.visible = false
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

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
	var has_valid_building: bool = current_building_node != null and is_instance_valid(current_building_node)
	var has_town: bool = current_town_node != null and is_instance_valid(current_town_node)

	_refresh_title(has_valid_building)
	_refresh_identity_section(has_town, has_valid_building)
	_refresh_capacity_section(has_town, has_valid_building)
	_refresh_service_section(has_town, has_valid_building)
	_refresh_worker_section(has_town, has_valid_building)
	_refresh_upgrade_section(has_town, has_valid_building)
	_refresh_policy_section(has_town, has_valid_building)

func _refresh_title(has_valid_building: bool) -> void:
	if not has_valid_building:
		title_label.text = "Building Details"
		return

	if current_building_id == "general_store":
		title_label.text = "General Store"
	elif current_building_id == "inn":
		title_label.text = "Inn"
	elif current_building_id == "guild_hall":
		title_label.text = "Guild Hall"
	else:
		title_label.text = current_building_id.capitalize()

func _refresh_identity_section(has_town: bool, has_valid_building: bool) -> void:
	if identity_section_label == null:
		return

	var can_show: bool = has_town and has_valid_building and current_town_node.has_method("get_building_identity_summary")
	identity_section_label.visible = can_show

	if can_show:
		identity_section_label.text = "IDENTITY\n%s" % current_town_node.get_building_identity_summary(current_building_node)

func _refresh_capacity_section(has_town: bool, has_valid_building: bool) -> void:
	if capacity_section_label == null:
		return

	var can_show: bool = has_town and has_valid_building and current_town_node.has_method("get_building_capacity_queue_summary")
	capacity_section_label.visible = can_show

	if can_show:
		capacity_section_label.text = "CAPACITY / QUEUE\n%s" % current_town_node.get_building_capacity_queue_summary(current_building_node)

func _refresh_service_section(has_town: bool, has_valid_building: bool) -> void:
	if service_section_label == null:
		return

	var can_show: bool = has_town and has_valid_building and current_town_node.has_method("get_building_service_summary")
	service_section_label.visible = can_show

	if can_show:
		service_section_label.text = "SERVICE\n%s" % current_town_node.get_building_service_summary(current_building_node)

func _refresh_worker_section(has_town: bool, has_valid_building: bool) -> void:
	if worker_section_label == null:
		return

	var can_show_summary: bool = has_town and has_valid_building and current_town_node.has_method("get_building_worker_summary")
	worker_section_label.visible = can_show_summary

	if can_show_summary:
		worker_section_label.text = "WORKERS\n%s" % current_town_node.get_building_worker_summary(current_building_node)

	var can_adjust_workers: bool = has_town and has_valid_building and current_town_node.has_method("can_adjust_building_workers") and bool(current_town_node.can_adjust_building_workers(current_building_node))

	if add_worker_button != null:
		add_worker_button.visible = can_adjust_workers

	if remove_worker_button != null:
		remove_worker_button.visible = can_adjust_workers

func _refresh_upgrade_section(has_town: bool, has_valid_building: bool) -> void:
	if upgrade_section_label == null:
		return

	var can_show_summary: bool = has_town and has_valid_building and current_town_node.has_method("get_building_upgrade_summary")
	upgrade_section_label.visible = can_show_summary

	if can_show_summary:
		upgrade_section_label.text = "UPGRADES\n%s" % current_town_node.get_building_upgrade_summary(current_building_node)

	var can_upgrade: bool = has_town and has_valid_building and current_town_node.has_method("can_upgrade_building") and bool(current_town_node.can_upgrade_building(current_building_node))

	if upgrade_button != null:
		upgrade_button.visible = can_upgrade

func _refresh_policy_section(has_town: bool, has_valid_building: bool) -> void:
	if policy_section_label == null:
		return

	var show_general_store_policy: bool = has_valid_building and current_building_id == "general_store"

	policy_section_label.visible = show_general_store_policy
	toggle_slime_gel_button.visible = show_general_store_policy

	if show_general_store_policy:
		policy_section_label.text = "POLICY\nSlime Gel buying: %s" % GameState.get_general_store_buy_policy_text()
		toggle_slime_gel_button.text = "Toggle Slime Gel Buying (%s)" % GameState.get_general_store_buy_policy_text()

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

func _on_upgrade_pressed() -> void:
	if current_town_node != null and is_instance_valid(current_town_node) and current_town_node.has_method("upgrade_building"):
		current_town_node.upgrade_building(current_building_node)
		_refresh()

func _on_close_pressed() -> void:
	close()
