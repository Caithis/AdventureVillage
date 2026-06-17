extends Node2D

const ADVENTURER_SCENE: PackedScene = preload("res://scenes/adventurers/Adventurer.tscn")
const CLICKABLE_BUILDING_SCRIPT: Script = preload("res://scripts/buildings/ClickableBuilding.gd")
const FLOATING_TEXT_SCENE: PackedScene = preload("res://scenes/ui/FloatingText.tscn")

const GRID_SIZE := 16.0
const BUILDABLE_RECT := Rect2(Vector2(140, 90), Vector2(1000, 490))
const PLACEMENT_PADDING := 10.0
const ENTRANCE_EXIT_CLEARANCE_SIZE := Vector2(150, 100)

const BUILDING_COSTS := {
	"guild_hall": 250,
	"inn": 150,
	"general_store": 175,
}

const DEMOLISH_REFUND_RATIO := 0.50
const BUILDING_SAVE_PATH := "user://placed_buildings.json"
const BUILDING_SAVE_VERSION := 1
const ROUTING_MODE_TEXT := "Nearest Open"
const LOCAL_QUEUE_SLOT_SIZE := Vector2(14, 14)

const BUILDING_BASE_SERVICE_SECONDS := {
	"general_store": 1.75,
	"inn": 3.0,
}

const DEFAULT_WORKER_PLACEHOLDERS := {
	"general_store": 1,
	"inn": 1,
}

const WORKER_SPEED_BONUS_PER_WORKER := 0.20
const MAX_WORKER_PLACEHOLDER_COUNT := 3
const MIN_SERVICE_SECONDS := 0.50

const MAX_BUILDING_UPGRADE_LEVEL := 3
const UPGRADE_CAPACITY_BONUS_PER_LEVEL := {
	"general_store": 1,
	"inn": 1,
}
const UPGRADE_SERVICE_SPEED_BONUS_PER_LEVEL := 0.10
const BUILDING_UPGRADE_BASE_COSTS := {
	"guild_hall": 200,
	"general_store": 125,
	"inn": 150,
}

const BUILDING_CAPACITY := {
	"general_store": 2,
	"inn": 5,
}

const STORE_QUEUE_OFFSETS: Array[Vector2] = [
	Vector2(-72, 52),
	Vector2(-48, 52),
	Vector2(-24, 52),
	Vector2(0, 52),
	Vector2(24, 52),
]

const INN_QUEUE_OFFSETS: Array[Vector2] = [
	Vector2(-84, 58),
	Vector2(-56, 58),
	Vector2(-28, 58),
	Vector2(0, 58),
	Vector2(28, 58),
	Vector2(56, 58),
	Vector2(84, 58),
]

@onready var buildings_container: Node2D = $Buildings
@onready var adventurers_container: Node2D = $Adventurers
@onready var town_entrance: Marker2D = $Markers/TownEntrance
@onready var general_store_point: Marker2D = $Markers/GeneralStorePoint
@onready var inn_point: Marker2D = $Markers/InnPoint
@onready var exit_to_world_point: Marker2D = $Markers/ExitToWorldPoint
@onready var building_menu: Control = $BuildingMenu

var spawn_count: int = 0
var return_spawn_count: int = 0
var placed_building_count: int = 0
var next_building_instance_number: int = 1
var is_checking_returned_travelers: bool = false

var active_building_type: String = ""
var build_action: String = "place"
var selected_building: ColorRect = null
var moving_building: ColorRect = null
var selected_outline: ColorRect = null
var build_ghost: ColorRect = null
var build_ghost_label: Label = null
var build_panel: PanelContainer = null
var build_panel_root_container: VBoxContainer = null
var build_panel_collapse_button: Button = null
var build_panel_collapsed: bool = false
var build_status_label: Label = null
var buildable_area_overlay: ColorRect = null

var fallback_general_store_position: Vector2 = Vector2.ZERO
var fallback_inn_position: Vector2 = Vector2.ZERO
var active_store_route_visual: Node2D = null
var active_inn_route_visual: Node2D = null
var last_selected_route_targets: Dictionary = {
	"general_store": "",
	"inn": "",
}

var active_building_instance_ids: Dictionary = {
	"general_store": "",
	"inn": "",
}

var building_occupants: Dictionary = {}
var building_waiting_queues: Dictionary = {}

func _ready() -> void:
	print("Town scene loaded.")
	fallback_general_store_position = general_store_point.global_position
	fallback_inn_position = inn_point.global_position
	GameState.state_changed.connect(_on_game_state_changed)
	_register_existing_buildings()
	_mark_fixed_fallback_buildings()
	load_placed_buildings_from_file(false)
	_create_build_panel()
	_create_entrance_exit_visuals()
	_create_active_route_visuals()
	_create_queue_slot_visuals()
	_refresh_dynamic_route_markers()
	_check_for_returned_travelers()

func _process(_delta: float) -> void:
	if active_building_type != "":
		_update_build_ghost()

func _input(event: InputEvent) -> void:
	if active_building_type == "":
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton

		if not mouse_event.pressed:
			return

		var mouse_position := get_global_mouse_position()
		if _is_mouse_over_ui(mouse_position):
			return

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			print("Build placement left-click received.")
			_try_place_active_building()
			get_viewport().set_input_as_handled()

		elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			print("Build placement right-click cancel received.")
			cancel_build_mode()
			get_viewport().set_input_as_handled()


func _is_mouse_over_ui(mouse_position: Vector2) -> bool:
	if build_panel != null and _control_contains_global_point(build_panel, mouse_position):
		return true

	if building_menu != null and building_menu.visible and _control_contains_global_point(building_menu, mouse_position):
		return true

	return false

func _control_contains_global_point(control: Control, point: Vector2) -> bool:
	if control == null:
		return false

	return Rect2(control.global_position, control.size).has_point(point)

func _exit_tree() -> void:
	if GameState.state_changed.is_connected(_on_game_state_changed):
		GameState.state_changed.disconnect(_on_game_state_changed)

func spawn_placeholder_adventurer() -> void:
	_refresh_dynamic_route_markers()
	var adventurer := ADVENTURER_SCENE.instantiate()
	adventurers_container.add_child(adventurer)

	var spawn_offset := Vector2((spawn_count % 8) * 24, -floori(float(spawn_count) / 8.0) * 24)
	var queue_offset := Vector2((spawn_count % 4) * 18, floori(float(spawn_count) / 4.0) * 12)

	var entrance_position := town_entrance.global_position + spawn_offset
	var exit_position := exit_to_world_point.global_position + Vector2(0, spawn_offset.y)

	adventurer.global_position = entrance_position

	if adventurer.has_method("setup_placeholder"):
		adventurer.setup_placeholder(_generate_adventurer_name(), "fighter", 1)

	var shop_position := assign_building_route_for_adventurer("general_store", adventurer, entrance_position) + queue_offset

	if adventurer.has_method("start_town_routine"):
		adventurer.start_town_routine(
			entrance_position,
			shop_position,
			exit_position
		)

	GameState.register_adventurer(adventurer)

	spawn_count += 1
	print("Spawned adventurer: ", adventurer.name)

func _on_game_state_changed() -> void:
	_check_for_returned_travelers()

func _check_for_returned_travelers() -> void:
	if is_checking_returned_travelers:
		return

	is_checking_returned_travelers = true
	var returned := GameState.claim_unclaimed_returned_travelers()

	for traveler_data in returned:
		_spawn_returned_adventurer(traveler_data)

	is_checking_returned_travelers = false

func _spawn_returned_adventurer(traveler_data: Dictionary) -> void:
	_refresh_dynamic_route_markers()
	var adventurer := ADVENTURER_SCENE.instantiate()
	adventurers_container.add_child(adventurer)

	var return_offset := Vector2((return_spawn_count % 5) * 22, -floori(float(return_spawn_count) / 5.0) * 22)
	var spawn_position := exit_to_world_point.global_position + Vector2(-65, -20) + return_offset
	var queue_offset := Vector2((return_spawn_count % 4) * 18, 24 + floori(float(return_spawn_count) / 4.0) * 12)
	var exit_position := exit_to_world_point.global_position + Vector2(0, return_offset.y)

	adventurer.global_position = spawn_position

	if adventurer.has_method("setup_from_traveler_data"):
		adventurer.setup_from_traveler_data(traveler_data)

	var shop_position := assign_building_route_for_adventurer("general_store", adventurer, spawn_position) + queue_offset
	var inn_position := assign_building_route_for_adventurer("inn", adventurer, spawn_position) + queue_offset

	if adventurer.has_method("start_return_to_town_routine"):
		adventurer.start_return_to_town_routine(spawn_position, shop_position, inn_position, exit_position)

	GameState.register_adventurer(adventurer)

	return_spawn_count += 1
	print("Returned adventurer re-entered town: ", adventurer.name)

func _generate_adventurer_name() -> String:
	var names: Array[String] = [
		"Rook",
		"Mira",
		"Bram",
		"Tessa",
		"Galen",
		"Nia",
		"Orin",
		"Lysa",
		"Perrin",
        "Sable"
	]

	return names[spawn_count % names.size()]

func _mark_fixed_fallback_buildings() -> void:
	for building in buildings_container.get_children():
		building.set_meta("is_fixed_fallback", true)

		var building_id := str(building.get("building_id"))
		if not building.has_meta("upgrade_level"):
			building.set_meta("upgrade_level", 0)

		if _is_queue_capable_building_type(building_id) and not building.has_meta("worker_count"):
			building.set_meta("worker_count", _get_default_worker_count(building_id))

		var label := building.get_node_or_null("Label") as Label
		if label == null:
			label = building.get_node_or_null("BuildingLabel") as Label

		if label != null:
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if not label.text.contains("Fixed"):
				label.text = "%s\n(Fixed Test)" % label.text

func _register_existing_buildings() -> void:
	for building in buildings_container.get_children():
		if building.has_signal("building_clicked"):
			var callback := Callable(self, "_on_building_clicked")
			if not building.is_connected("building_clicked", callback):
				building.connect("building_clicked", callback)

func _on_building_clicked(building_id: String, building_node: Node = null) -> void:
	if active_building_type != "":
		return

	if building_node is ColorRect:
		select_building(building_node as ColorRect)

	if building_menu != null and building_menu.has_method("open_for_building"):
		building_menu.open_for_building(building_id, building_node, self)

func _create_build_panel() -> void:
	build_panel = PanelContainer.new()
	build_panel.name = "BuildPanel"
	build_panel.position = Vector2(930, 12)
	build_panel.size = Vector2(290, 300)
	build_panel.custom_minimum_size = Vector2(290, 300)
	build_panel.z_index = 100
	build_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(build_panel)

	var vbox := VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	build_panel.add_child(vbox)
	build_panel_root_container = vbox

	build_panel_collapse_button = Button.new()
	build_panel_collapse_button.text = "Hide Build Menu"
	build_panel_collapse_button.focus_mode = Control.FOCUS_NONE
	build_panel_collapse_button.pressed.connect(_on_toggle_build_panel_collapsed)
	vbox.add_child(build_panel_collapse_button)

	var title_label := Label.new()
	title_label.text = "Build Mode"
	vbox.add_child(title_label)

	var note_label := Label.new()
	note_label.text = "Select a building, move ghost, left-click to place, right-click to cancel. Costs apply to new placement."
	note_label.autowrap_mode = 3
	vbox.add_child(note_label)

	var guild_button := Button.new()
	guild_button.text = "Build Guild Hall (%dg)" % get_building_cost("guild_hall")
	guild_button.focus_mode = Control.FOCUS_NONE
	guild_button.pressed.connect(_on_build_button_pressed.bind("guild_hall"))
	vbox.add_child(guild_button)

	var inn_button := Button.new()
	inn_button.text = "Build Inn (%dg)" % get_building_cost("inn")
	inn_button.focus_mode = Control.FOCUS_NONE
	inn_button.pressed.connect(_on_build_button_pressed.bind("inn"))
	vbox.add_child(inn_button)

	var store_button := Button.new()
	store_button.text = "Build General Store (%dg)" % get_building_cost("general_store")
	store_button.focus_mode = Control.FOCUS_NONE
	store_button.pressed.connect(_on_build_button_pressed.bind("general_store"))
	vbox.add_child(store_button)

	var move_button := Button.new()
	move_button.text = "Move Selected"
	move_button.focus_mode = Control.FOCUS_NONE
	move_button.pressed.connect(_on_move_selected_button_pressed)
	vbox.add_child(move_button)

	var demolish_button := Button.new()
	demolish_button.text = "Demolish Selected"
	demolish_button.focus_mode = Control.FOCUS_NONE
	demolish_button.pressed.connect(_on_demolish_selected_button_pressed)
	vbox.add_child(demolish_button)

	var save_button := Button.new()
	save_button.text = "Save Buildings"
	save_button.focus_mode = Control.FOCUS_NONE
	save_button.pressed.connect(_on_save_buildings_button_pressed)
	vbox.add_child(save_button)

	var load_button := Button.new()
	load_button.text = "Load Buildings"
	load_button.focus_mode = Control.FOCUS_NONE
	load_button.pressed.connect(_on_load_buildings_button_pressed)
	vbox.add_child(load_button)

	var cancel_button := Button.new()
	cancel_button.text = "Cancel Build / Move"
	cancel_button.focus_mode = Control.FOCUS_NONE
	cancel_button.pressed.connect(cancel_build_mode)
	vbox.add_child(cancel_button)

	build_status_label = Label.new()
	build_status_label.text = "Build status: inactive"
	build_status_label.autowrap_mode = 3
	vbox.add_child(build_status_label)

func _on_toggle_build_panel_collapsed() -> void:
	build_panel_collapsed = not build_panel_collapsed

	if build_panel_root_container == null:
		return

	for child in build_panel_root_container.get_children():
		if child == build_panel_collapse_button:
			continue

		child.visible = not build_panel_collapsed

	if build_panel_collapsed:
		build_panel_collapse_button.text = "Show Build Menu"
		build_panel.custom_minimum_size = Vector2(290, 40)
		build_panel.size = Vector2(290, 40)
	else:
		build_panel_collapse_button.text = "Hide Build Menu"
		build_panel.custom_minimum_size = Vector2(290, 300)
		build_panel.size = Vector2(290, 300)

func _on_build_button_pressed(building_type: String) -> void:
	print("Build button pressed: ", building_type)
	start_build_mode(building_type)

func start_build_mode(building_type: String) -> void:
	build_action = "place"
	moving_building = null
	active_building_type = building_type
	_ensure_build_ghost()
	_ensure_buildable_area_overlay()
	build_ghost.visible = true
	buildable_area_overlay.visible = true
	_update_build_status("Placing %s | Cost %dg | Funds %dg" % [_get_building_display_name(active_building_type), get_building_cost(active_building_type), GameState.money])
	_update_build_ghost()

func cancel_build_mode() -> void:
	if build_action == "move" and moving_building != null:
		moving_building.visible = true
		selected_building = moving_building
		_update_selected_outline()

	active_building_type = ""
	build_action = "place"
	moving_building = null

	if build_ghost != null:
		build_ghost.visible = false

	if buildable_area_overlay != null:
		buildable_area_overlay.visible = false

	_update_build_status("Build status: inactive")

func _ensure_build_ghost() -> void:
	if build_ghost != null:
		return

	build_ghost = ColorRect.new()
	build_ghost.name = "BuildGhost"
	build_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	build_ghost.z_index = 80
	build_ghost.visible = false
	add_child(build_ghost)

	build_ghost_label = Label.new()
	build_ghost_label.name = "GhostLabel"
	build_ghost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	build_ghost_label.position = Vector2(8, 8)
	build_ghost.add_child(build_ghost_label)

func _ensure_buildable_area_overlay() -> void:
	if buildable_area_overlay != null:
		return

	buildable_area_overlay = ColorRect.new()
	buildable_area_overlay.name = "BuildableAreaOverlay"
	buildable_area_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	buildable_area_overlay.position = BUILDABLE_RECT.position
	buildable_area_overlay.size = BUILDABLE_RECT.size
	buildable_area_overlay.color = Color(0.25, 0.9, 0.35, 0.08)
	buildable_area_overlay.z_index = 5
	buildable_area_overlay.visible = false
	add_child(buildable_area_overlay)

func _update_build_ghost() -> void:
	if build_ghost == null or active_building_type == "":
		return

	var placement_rect := _get_current_placement_rect()
	var validation := _get_placement_validation(active_building_type, placement_rect)
	var base_color := _get_building_color(active_building_type)

	build_ghost.position = placement_rect.position
	build_ghost.size = placement_rect.size

	if bool(validation.get("is_valid", false)):
		build_ghost.color = Color(0.2, 0.9, 0.35, 0.42)
		if build_action == "move":
			build_ghost_label.text = "%s\nMove Valid" % _get_building_display_name(active_building_type)
		else:
			build_ghost_label.text = "%s\nValid\nCost: %dg" % [_get_building_display_name(active_building_type), get_building_cost(active_building_type)]
	else:
		build_ghost.color = Color(1.0, 0.2, 0.2, 0.42)
		build_ghost_label.text = "%s\n%s" % [
			_get_building_display_name(active_building_type),
			str(validation.get("reason", "Invalid"))
		]

	build_ghost_label.size = placement_rect.size - Vector2(12, 12)
	build_ghost_label.position = Vector2(6, 6)

func _try_place_active_building() -> void:
	if active_building_type == "":
		return

	var placement_rect := _get_current_placement_rect()
	var validation := _get_placement_validation(active_building_type, placement_rect)

	if not bool(validation.get("is_valid", false)):
		print("Invalid placement: ", str(validation.get("reason", "Unknown reason")))
		_update_build_status("Invalid placement: %s" % str(validation.get("reason", "Unknown reason")))
		_update_build_ghost()
		return

	print("Placed building: ", active_building_type)
	if build_action == "move":
		_complete_move_selected_building(placement_rect)
	else:
		var building_cost := get_building_cost(active_building_type)
		if not GameState.spend_money(building_cost):
			_update_build_status("Not enough funds for %s. Need %dg, have %dg." % [_get_building_display_name(active_building_type), building_cost, GameState.money])
			show_town_floating_text("Need %dg" % building_cost, placement_rect.position + placement_rect.size * 0.5)
			return

		_place_building(active_building_type, placement_rect)
		_refresh_dynamic_route_markers()
		save_placed_buildings_to_file(false)
		show_town_floating_text("-%dg %s" % [building_cost, _get_building_display_name(active_building_type)], placement_rect.position + placement_rect.size * 0.5)
		_update_build_status("Placed %s for %dg. Funds %dg." % [_get_building_display_name(active_building_type), building_cost, GameState.money])
	cancel_build_mode()

func _place_building(building_type: String, placement_rect: Rect2) -> ColorRect:
	placed_building_count += 1

	var building := ColorRect.new()
	building.name = "%s_Placed_%d" % [building_type, placed_building_count]
	building.set_script(CLICKABLE_BUILDING_SCRIPT)
	building.set("building_id", building_type)
	building.set("normal_color", _get_building_color(building_type))
	building.set("hover_color", Color(0.95, 0.85, 0.35, 1.0))
	building.position = placement_rect.position
	building.size = placement_rect.size
	building.color = _get_building_color(building_type)
	building.set_meta("is_fixed_fallback", false)
	building.set_meta("is_placed_building", true)
	building.set_meta("original_cost", get_building_cost(building_type))
	building.set_meta("worker_count", _get_default_worker_count(building_type))
	building.set_meta("upgrade_level", 0)
	var instance_id := _assign_new_building_instance_id(building, building_type)

	buildings_container.add_child(building)

	var label := Label.new()
	label.name = "BuildingLabel"
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.position = Vector2(10, 8)
	label.size = Vector2(placement_rect.size.x - 20, placement_rect.size.y - 16)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	building.add_child(label)
	_update_placed_building_label(building)

	if building.has_signal("building_clicked"):
		building.connect("building_clicked", Callable(self, "_on_building_clicked"))

	return building


func select_building(building: ColorRect) -> void:
	selected_building = building
	_update_selected_outline()

	if bool(building.get_meta("is_fixed_fallback", false)):
		_update_build_status("Selected %s. Fixed fallback is protected." % _get_building_display_name(str(building.get("building_id"))))
	else:
		_update_build_status("Selected %s %s. Move or demolish. Refund: %dg." % [_get_building_display_name(str(building.get("building_id"))), _ensure_building_instance_id(building), get_demolish_refund(building)])

func clear_selected_building() -> void:
	selected_building = null

	if selected_outline != null:
		selected_outline.queue_free()
		selected_outline = null

func _update_selected_outline() -> void:
	if selected_outline != null:
		selected_outline.queue_free()
		selected_outline = null

	if selected_building == null:
		return

	selected_outline = ColorRect.new()
	selected_outline.name = "SelectedOutline"
	selected_outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selected_outline.position = Vector2(-7, -7)
	selected_outline.size = selected_building.size + Vector2(14, 14)
	selected_outline.color = Color(0.2, 0.75, 1.0, 0.38)
	selected_outline.z_index = 90
	selected_building.add_child(selected_outline)
	selected_building.move_child(selected_outline, 0)

func _on_move_selected_button_pressed() -> void:
	if selected_building == null:
		_update_build_status("Select a placed building first.")
		return

	if bool(selected_building.get_meta("is_fixed_fallback", false)):
		_update_build_status("Fixed fallback buildings are protected for now.")
		return

	start_move_selected_building()

func start_move_selected_building() -> void:
	if selected_building == null:
		return

	build_action = "move"
	moving_building = selected_building
	active_building_type = str(selected_building.get("building_id"))
	_ensure_build_ghost()
	_ensure_buildable_area_overlay()
	build_ghost.visible = true
	buildable_area_overlay.visible = true
	moving_building.visible = false
	_update_build_status("Moving %s. No cost. Left-click valid area to confirm, right-click to cancel." % _get_building_display_name(active_building_type))
	_update_build_ghost()

func _complete_move_selected_building(placement_rect: Rect2) -> void:
	if moving_building == null:
		return

	moving_building.position = placement_rect.position
	moving_building.size = placement_rect.size
	moving_building.visible = true
	selected_building = moving_building
	moving_building = null
	_update_selected_outline()
	_refresh_dynamic_route_markers()
	save_placed_buildings_to_file(false)
	_update_build_status("Moved %s. Routes updated." % _get_building_display_name(active_building_type))

func _on_demolish_selected_button_pressed() -> void:
	if selected_building == null:
		_update_build_status("Select a placed building first.")
		return

	if bool(selected_building.get_meta("is_fixed_fallback", false)):
		_update_build_status("Fixed fallback buildings are protected for now.")
		return

	var building_id := str(selected_building.get("building_id"))
	var demolished_name := _get_building_display_name(building_id)
	var refund_amount := get_demolish_refund(selected_building)
	var floating_position := selected_building.global_position + selected_building.size * 0.5
	var building_to_remove := selected_building

	clear_selected_building()

	if building_to_remove.get_parent() != null:
		building_to_remove.get_parent().remove_child(building_to_remove)

	building_to_remove.queue_free()
	_refresh_dynamic_route_markers()
	save_placed_buildings_to_file(false)

	if refund_amount > 0:
		GameState.add_money(refund_amount)
		show_town_floating_text("+%dg refund" % refund_amount, floating_position)
		_update_build_status("Demolished %s. Refunded %dg. Funds %dg." % [demolished_name, refund_amount, GameState.money])
	else:
		_update_build_status("Demolished %s. No refund." % demolished_name)

func _get_current_placement_rect() -> Rect2:
	var building_size := _get_building_size(active_building_type)
	var mouse_position := get_global_mouse_position()
	var snapped_position := _snap_to_grid(mouse_position)
	return Rect2(snapped_position - building_size * 0.5, building_size)

func _snap_to_grid(position_to_snap: Vector2) -> Vector2:
	return Vector2(
		round(position_to_snap.x / GRID_SIZE) * GRID_SIZE,
		round(position_to_snap.y / GRID_SIZE) * GRID_SIZE
	)

func _get_placement_validation(building_type: String, placement_rect: Rect2) -> Dictionary:
	if building_type == "":
		return {"is_valid": false, "reason": "No building selected"}

	if not BUILDABLE_RECT.encloses(placement_rect):
		return {"is_valid": false, "reason": "Outside build area"}

	if build_action != "move" and GameState.money < get_building_cost(building_type):
		return {"is_valid": false, "reason": "Need %dg" % get_building_cost(building_type)}

	if _overlaps_existing_building(placement_rect):
		return {"is_valid": false, "reason": "Overlaps building"}

	if _overlaps_entrance_or_exit_clearance(placement_rect):
		return {"is_valid": false, "reason": "Blocks entrance/exit"}

	return {"is_valid": true, "reason": "Valid"}

func _overlaps_existing_building(placement_rect: Rect2) -> bool:
	var padded_placement := placement_rect.grow(PLACEMENT_PADDING)

	for building in buildings_container.get_children():
		if building == moving_building:
			continue

		if building is ColorRect:
			var building_control := building as ColorRect
			var building_rect := Rect2(building_control.global_position, building_control.size).grow(PLACEMENT_PADDING)

			if padded_placement.intersects(building_rect):
				return true

	return false

func _overlaps_entrance_or_exit_clearance(placement_rect: Rect2) -> bool:
	var entrance_rect := Rect2(
		town_entrance.global_position - ENTRANCE_EXIT_CLEARANCE_SIZE * 0.5,
		ENTRANCE_EXIT_CLEARANCE_SIZE
	)

	var exit_rect := Rect2(
		exit_to_world_point.global_position - ENTRANCE_EXIT_CLEARANCE_SIZE * 0.5,
		ENTRANCE_EXIT_CLEARANCE_SIZE
	)

	return placement_rect.intersects(entrance_rect) or placement_rect.intersects(exit_rect)


func get_building_cost(building_type: String) -> int:
	return int(BUILDING_COSTS.get(building_type, 100))

func get_demolish_refund(building: ColorRect) -> int:
	if building == null:
		return 0

	var original_cost := int(building.get_meta("original_cost", get_building_cost(str(building.get("building_id")))))
	return floori(float(original_cost) * DEMOLISH_REFUND_RATIO)

func show_town_floating_text(text: String, world_position: Vector2) -> void:
	var floating_text := FLOATING_TEXT_SCENE.instantiate()
	add_child(floating_text)
	floating_text.global_position = world_position + Vector2(0, -36)

	if floating_text.has_method("setup"):
		floating_text.setup(text)



func _on_save_buildings_button_pressed() -> void:
	save_placed_buildings_to_file(true)

func _on_load_buildings_button_pressed() -> void:
	load_placed_buildings_from_file(true)

func save_placed_buildings_to_file(show_feedback: bool = true) -> void:
	var placed_buildings_data: Array[Dictionary] = []

	for building in buildings_container.get_children():
		if not building is ColorRect:
			continue

		var building_control := building as ColorRect
		if bool(building_control.get_meta("is_fixed_fallback", false)):
			continue

		if not bool(building_control.get_meta("is_placed_building", false)):
			continue

		placed_buildings_data.append({
			"building_type": str(building_control.get("building_id")),
			"building_instance_id": _ensure_building_instance_id(building_control),
			"position_x": building_control.position.x,
			"position_y": building_control.position.y,
			"size_x": building_control.size.x,
			"size_y": building_control.size.y,
			"original_cost": int(building_control.get_meta("original_cost", get_building_cost(str(building_control.get("building_id"))))),
			"worker_count": get_worker_count_for_building(building_control),
			"upgrade_level": get_upgrade_level_for_building(building_control)
		})

	var save_data: Dictionary = {
		"version": BUILDING_SAVE_VERSION,
		"next_building_instance_number": next_building_instance_number,
		"placed_buildings": placed_buildings_data
	}

	var file := FileAccess.open(BUILDING_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		var error_text := "Building save failed. File error %s." % str(FileAccess.get_open_error())
		_update_build_status(error_text)
		if show_feedback:
			show_town_floating_text("Save Failed", Vector2(620, 120))
		return

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()

	if show_feedback:
		_update_build_status("Saved %d placed building(s)." % placed_buildings_data.size())
		show_town_floating_text("Buildings Saved", Vector2(620, 120))

func load_placed_buildings_from_file(show_feedback: bool = true) -> void:
	if not FileAccess.file_exists(BUILDING_SAVE_PATH):
		if show_feedback:
			_update_build_status("No building save found yet.")
			show_town_floating_text("No Save Found", Vector2(620, 120))
		return

	var file := FileAccess.open(BUILDING_SAVE_PATH, FileAccess.READ)
	if file == null:
		var error_text := "Building load failed. File error %s." % str(FileAccess.get_open_error())
		_update_build_status(error_text)
		if show_feedback:
			show_town_floating_text("Load Failed", Vector2(620, 120))
		return

	var file_text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(file_text)
	if not parsed is Dictionary:
		_update_build_status("Building save data is invalid.")
		if show_feedback:
			show_town_floating_text("Invalid Save", Vector2(620, 120))
		return

	var save_data: Dictionary = parsed
	next_building_instance_number = maxi(1, int(save_data.get("next_building_instance_number", next_building_instance_number)))
	var placed_buildings_data: Array = save_data.get("placed_buildings", [])

	clear_selected_building()
	_reset_building_capacity()
	_remove_all_placed_buildings()

	for building_data in placed_buildings_data:
		if not building_data is Dictionary:
			continue

		_recreate_placed_building_from_save(building_data)

	_refresh_dynamic_route_markers()

	if show_feedback:
		_update_build_status("Loaded %d placed building(s)." % placed_buildings_data.size())
		show_town_floating_text("Buildings Loaded", Vector2(620, 120))

func _remove_all_placed_buildings() -> void:
	for index in range(buildings_container.get_child_count() - 1, -1, -1):
		var building := buildings_container.get_child(index)

		if not building is ColorRect:
			continue

		var building_control := building as ColorRect
		if bool(building_control.get_meta("is_fixed_fallback", false)):
			continue

		if bool(building_control.get_meta("is_placed_building", false)):
			buildings_container.remove_child(building_control)
			building_control.queue_free()

func _recreate_placed_building_from_save(building_data: Dictionary) -> void:
	var building_type: String = str(building_data.get("building_type", "building"))
	var position := Vector2(
		float(building_data.get("position_x", 160.0)),
		float(building_data.get("position_y", 120.0))
	)
	var size := Vector2(
		float(building_data.get("size_x", _get_building_size(building_type).x)),
		float(building_data.get("size_y", _get_building_size(building_type).y))
	)
	var placement_rect := Rect2(position, size)

	var building := _place_building(building_type, placement_rect)
	if building != null:
		var saved_instance_id: String = str(building_data.get("building_instance_id", ""))
		if saved_instance_id != "":
			building.set_meta("building_instance_id", saved_instance_id)
			_advance_next_building_instance_number_from_id(saved_instance_id)
			_update_placed_building_label(building)
		else:
			_ensure_building_instance_id(building)

		building.set_meta("original_cost", int(building_data.get("original_cost", get_building_cost(building_type))))
		building.set_meta("worker_count", int(building_data.get("worker_count", _get_default_worker_count(building_type))))
		building.set_meta("upgrade_level", int(building_data.get("upgrade_level", 0)))
		_update_local_building_visuals(building)




func request_building_capacity(building_type: String, adventurer: Node) -> bool:
	if adventurer == null:
		return false

	var instance_id := _get_preferred_instance_id_for_adventurer(building_type, adventurer)

	if _is_instance_full(building_type, instance_id) and _has_available_placed_building(building_type):
		assign_building_route_for_adventurer(building_type, adventurer, adventurer.global_position)
		instance_id = _get_preferred_instance_id_for_adventurer(building_type, adventurer)

	_cleanup_building_occupants(instance_id)
	_cleanup_building_queue(instance_id)

	var occupants: Array = building_occupants.get(instance_id, [])

	if occupants.has(adventurer):
		release_building_queue_slot(building_type, adventurer)
		adventurer.set_meta(_get_capacity_meta_key(building_type), instance_id)
		return true

	if occupants.size() >= get_building_capacity_for_instance(building_type, instance_id):
		request_building_queue_slot(building_type, adventurer)
		_update_active_route_visuals()
		return false

	release_building_queue_slot(building_type, adventurer)
	occupants.append(adventurer)
	building_occupants[instance_id] = occupants
	adventurer.set_meta(_get_capacity_meta_key(building_type), instance_id)
	_update_active_route_visuals()
	return true

func release_building_capacity(building_type: String, adventurer: Node) -> void:
	if adventurer == null:
		return

	var released_any := false
	var meta_key := _get_capacity_meta_key(building_type)

	if adventurer.has_meta(meta_key):
		var instance_id := str(adventurer.get_meta(meta_key))
		released_any = _remove_adventurer_from_occupants(instance_id, adventurer) or released_any
		adventurer.remove_meta(meta_key)

	for instance_id in building_occupants.keys():
		released_any = _remove_adventurer_from_occupants(str(instance_id), adventurer) or released_any

	if released_any:
		_update_active_route_visuals()

func _remove_adventurer_from_occupants(instance_id: String, adventurer: Node) -> bool:
	var occupants: Array = building_occupants.get(instance_id, [])
	if occupants.has(adventurer):
		occupants.erase(adventurer)
		building_occupants[instance_id] = occupants
		return true

	return false

func request_building_queue_slot(building_type: String, adventurer: Node) -> Vector2:
	if adventurer == null:
		return _get_active_building_route_position(building_type)

	var instance_id := _get_preferred_instance_id_for_adventurer(building_type, adventurer)
	_cleanup_building_queue(instance_id)

	var queue: Array = building_waiting_queues.get(instance_id, [])
	if not queue.has(adventurer):
		queue.append(adventurer)
		building_waiting_queues[instance_id] = queue

	adventurer.set_meta(_get_queue_meta_key(building_type), instance_id)
	_update_active_route_visuals()
	return get_queue_slot_position(building_type, adventurer)

func release_building_queue_slot(building_type: String, adventurer: Node) -> void:
	if adventurer == null:
		return

	var released_any := false
	var meta_key := _get_queue_meta_key(building_type)

	if adventurer.has_meta(meta_key):
		var instance_id := str(adventurer.get_meta(meta_key))
		released_any = _remove_adventurer_from_queue(instance_id, adventurer) or released_any
		adventurer.remove_meta(meta_key)

	for instance_id in building_waiting_queues.keys():
		released_any = _remove_adventurer_from_queue(str(instance_id), adventurer) or released_any

	if released_any:
		_update_active_route_visuals()

func _remove_adventurer_from_queue(instance_id: String, adventurer: Node) -> bool:
	var queue: Array = building_waiting_queues.get(instance_id, [])
	if queue.has(adventurer):
		queue.erase(adventurer)
		building_waiting_queues[instance_id] = queue
		return true

	return false

func release_all_building_capacity_for_adventurer(adventurer: Node) -> void:
	release_building_capacity("general_store", adventurer)
	release_building_capacity("inn", adventurer)
	release_building_queue_slot("general_store", adventurer)
	release_building_queue_slot("inn", adventurer)

func get_queue_slot_position(building_type: String, adventurer: Node) -> Vector2:
	var instance_id := _get_preferred_instance_id_for_adventurer(building_type, adventurer)
	var route_position := _get_building_route_position_for_instance(building_type, instance_id)
	var queue: Array = building_waiting_queues.get(instance_id, [])
	var index: int = queue.find(adventurer)

	if index < 0:
		index = queue.size()

	var offsets := _get_queue_offsets(building_type)
	if offsets.is_empty():
		return route_position + Vector2(0, 64)

	if index < offsets.size():
		return route_position + offsets[index]

	var overflow_index := index - offsets.size()
	return route_position + offsets[offsets.size() - 1] + Vector2(0, float(overflow_index + 1) * 24.0)

func get_building_capacity(building_type: String) -> int:
	return int(BUILDING_CAPACITY.get(building_type, 1))

func get_building_capacity_for_building(building: ColorRect) -> int:
	if building == null:
		return 1

	var building_type := str(building.get("building_id"))
	return get_building_capacity_for_level(building_type, get_upgrade_level_for_building(building))

func get_building_capacity_for_instance(building_type: String, instance_id: String) -> int:
	return get_building_capacity_for_level(building_type, get_upgrade_level_for_instance(building_type, instance_id))

func get_building_capacity_for_level(building_type: String, upgrade_level: int) -> int:
	var base_capacity: int = get_building_capacity(building_type)
	var upgrade_capacity_bonus: int = int(UPGRADE_CAPACITY_BONUS_PER_LEVEL.get(building_type, 0))
	var capacity_bonus: int = upgrade_capacity_bonus * maxi(upgrade_level, 0)
	return base_capacity + capacity_bonus

func get_building_occupancy_count(building_type: String) -> int:
	var instance_id := _get_active_building_instance_id(building_type)
	_cleanup_building_occupants(instance_id)
	var occupants: Array = building_occupants.get(instance_id, [])
	return occupants.size()

func get_building_queue_count(building_type: String) -> int:
	var instance_id := _get_active_building_instance_id(building_type)
	_cleanup_building_queue(instance_id)
	var queue: Array = building_waiting_queues.get(instance_id, [])
	return queue.size()

func get_building_capacity_summary(building_type: String) -> String:
	if _count_placed_buildings_of_type(building_type) <= 0:
		return "%d/%d occupied | Q:%d" % [
			get_building_occupancy_count(building_type),
			get_building_capacity_for_instance(building_type, _get_active_building_instance_id(building_type)),
			get_building_queue_count(building_type)
		]

	return "Mode:%s | B:%d | Open:%d/%d | Q:%d" % [
		ROUTING_MODE_TEXT,
		_count_placed_buildings_of_type(building_type),
		_get_total_open_slots_for_type(building_type),
		_get_total_capacity_for_type(building_type),
		_get_total_queue_count_for_type(building_type)
	]

func _cleanup_building_occupants(instance_id: String) -> void:
	var occupants: Array = building_occupants.get(instance_id, [])
	var valid_occupants: Array = []

	for occupant in occupants:
		if is_instance_valid(occupant):
			valid_occupants.append(occupant)

	building_occupants[instance_id] = valid_occupants

func _cleanup_building_queue(instance_id: String) -> void:
	var queue: Array = building_waiting_queues.get(instance_id, [])
	var valid_queue: Array = []

	for occupant in queue:
		if is_instance_valid(occupant):
			valid_queue.append(occupant)

	building_waiting_queues[instance_id] = valid_queue

func _reset_building_capacity() -> void:
	building_occupants.clear()
	building_waiting_queues.clear()
	_update_active_route_visuals()

func _cleanup_inactive_building_instance_state() -> void:
	var valid_instance_ids := _get_all_valid_building_instance_ids()

	for instance_id in building_occupants.keys():
		if not valid_instance_ids.has(str(instance_id)):
			building_occupants.erase(instance_id)

	for instance_id in building_waiting_queues.keys():
		if not valid_instance_ids.has(str(instance_id)):
			building_waiting_queues.erase(instance_id)

func _get_all_valid_building_instance_ids() -> Array[String]:
	var ids: Array[String] = [
		_get_fallback_instance_id("general_store"),
		_get_fallback_instance_id("inn")
	]

	for building in buildings_container.get_children():
		if not building is ColorRect:
			continue

		var building_control := building as ColorRect
		if bool(building_control.get_meta("is_fixed_fallback", false)):
			continue

		if bool(building_control.get_meta("is_placed_building", false)):
			ids.append(_ensure_building_instance_id(building_control))

	return ids

func _get_queue_offsets(building_type: String) -> Array[Vector2]:
	if building_type == "general_store":
		return STORE_QUEUE_OFFSETS

	if building_type == "inn":
		return INN_QUEUE_OFFSETS

	return []

func _get_capacity_meta_key(building_type: String) -> String:
	return "capacity_instance_%s" % building_type

func _get_queue_meta_key(building_type: String) -> String:
	return "queue_instance_%s" % building_type

func _get_route_meta_key(building_type: String) -> String:
	return "route_instance_%s" % building_type

func _is_instance_full(building_type: String, instance_id: String) -> bool:
	_cleanup_building_occupants(instance_id)
	var occupants: Array = building_occupants.get(instance_id, [])
	return occupants.size() >= get_building_capacity_for_instance(building_type, instance_id)

func _has_available_placed_building(building_type: String) -> bool:
	for building in _get_placed_buildings_of_type(building_type):
		var instance_id := _ensure_building_instance_id(building)
		if not _is_instance_full(building_type, instance_id):
			return true

	return false

func _get_total_capacity_for_type(building_type: String) -> int:
	var placed_count := _count_placed_buildings_of_type(building_type)
	if placed_count <= 0:
		return get_building_capacity(building_type)

	var total_capacity: int = 0
	for instance_id in _get_routable_instance_ids_for_type(building_type):
		total_capacity += get_building_capacity_for_instance(building_type, instance_id)
	return total_capacity

func _get_total_open_slots_for_type(building_type: String) -> int:
	var instance_ids := _get_routable_instance_ids_for_type(building_type)
	var open_slots: int = 0

	for instance_id in instance_ids:
		_cleanup_building_occupants(instance_id)
		var occupants: Array = building_occupants.get(instance_id, [])
		open_slots += maxi(get_building_capacity_for_instance(building_type, instance_id) - occupants.size(), 0)

	return open_slots

func _get_total_queue_count_for_type(building_type: String) -> int:
	var instance_ids := _get_routable_instance_ids_for_type(building_type)
	var queue_total: int = 0

	for instance_id in instance_ids:
		_cleanup_building_queue(instance_id)
		var queue: Array = building_waiting_queues.get(instance_id, [])
		queue_total += queue.size()

	return queue_total

func _get_routable_instance_ids_for_type(building_type: String) -> Array[String]:
	var ids: Array[String] = []
	var placed_buildings := _get_placed_buildings_of_type(building_type)

	if placed_buildings.is_empty():
		ids.append(_get_fallback_instance_id(building_type))
		return ids

	for building in placed_buildings:
		ids.append(_ensure_building_instance_id(building))

	return ids


func _assign_new_building_instance_id(building: ColorRect, building_type: String) -> String:
	var instance_id := "%s_%03d" % [building_type, next_building_instance_number]
	next_building_instance_number += 1
	building.set_meta("building_instance_id", instance_id)
	return instance_id

func _ensure_building_instance_id(building: ColorRect) -> String:
	if building == null:
		return ""

	if building.has_meta("building_instance_id"):
		var existing_id := str(building.get_meta("building_instance_id"))
		if existing_id != "":
			return existing_id

	var building_type := str(building.get("building_id"))
	return _assign_new_building_instance_id(building, building_type)

func _advance_next_building_instance_number_from_id(instance_id: String) -> void:
	var parts := instance_id.split("_")
	if parts.is_empty():
		return

	var numeric_part := parts[parts.size() - 1]
	if numeric_part.is_valid_int():
		next_building_instance_number = maxi(next_building_instance_number, int(numeric_part) + 1)

func _get_fallback_instance_id(building_type: String) -> String:
	return "fallback_%s" % building_type

func _get_placed_buildings_of_type(building_type: String) -> Array:
	var placed_buildings: Array = []

	for building in buildings_container.get_children():
		if not building is ColorRect:
			continue

		var building_control := building as ColorRect
		if bool(building_control.get_meta("is_fixed_fallback", false)):
			continue

		if not bool(building_control.get_meta("is_placed_building", false)):
			continue

		if str(building_control.get("building_id")) != building_type:
			continue

		placed_buildings.append(building_control)

	return placed_buildings

func _count_placed_buildings_of_type(building_type: String) -> int:
	return _get_placed_buildings_of_type(building_type).size()

func _get_primary_placed_building(building_type: String) -> ColorRect:
	var chosen_building: ColorRect = null
	var placed_buildings := _get_placed_buildings_of_type(building_type)

	if placed_buildings.is_empty():
		return null

	for building in placed_buildings:
		chosen_building = building as ColorRect

	return chosen_building

func _get_active_building_instance_id(building_type: String) -> String:
	var placed_building := _get_primary_placed_building(building_type)
	if placed_building == null:
		return _get_fallback_instance_id(building_type)

	return _ensure_building_instance_id(placed_building)

func _get_fallback_route_position(building_type: String) -> Vector2:
	if building_type == "general_store":
		return fallback_general_store_position

	if building_type == "inn":
		return fallback_inn_position

	return Vector2.ZERO

func _get_building_by_instance_id(instance_id: String) -> ColorRect:
	if instance_id.begins_with("fallback_"):
		return null

	for building in buildings_container.get_children():
		if not building is ColorRect:
			continue

		var building_control := building as ColorRect
		if bool(building_control.get_meta("is_fixed_fallback", false)):
			continue

		if _ensure_building_instance_id(building_control) == instance_id:
			return building_control

	return null

func _is_building_instance_valid_for_type(building_type: String, instance_id: String) -> bool:
	if instance_id == _get_fallback_instance_id(building_type):
		return _count_placed_buildings_of_type(building_type) <= 0

	var building := _get_building_by_instance_id(instance_id)
	if building == null:
		return false

	return str(building.get("building_id")) == building_type

func _get_building_route_position_for_instance(building_type: String, instance_id: String) -> Vector2:
	if instance_id == _get_fallback_instance_id(building_type):
		return _get_fallback_route_position(building_type)

	var building := _get_building_by_instance_id(instance_id)
	if building == null:
		return _get_fallback_route_position(building_type)

	return building.global_position + building.size * 0.5

func _get_building_route_position(building_type: String, fallback_position: Vector2) -> Vector2:
	var placed_building := _get_primary_placed_building(building_type)

	if placed_building == null:
		return fallback_position

	return placed_building.global_position + placed_building.size * 0.5

func _get_active_building_route_position(building_type: String) -> Vector2:
	return _get_building_route_position(building_type, _get_fallback_route_position(building_type))

func _is_route_using_placed_building(building_type: String) -> bool:
	return _get_placed_buildings_of_type(building_type).size() > 0

func _get_active_route_source_text(building_type: String) -> String:
	if _count_placed_buildings_of_type(building_type) > 1:
		return "MODE %s" % ROUTING_MODE_TEXT

	var instance_id := _get_active_building_instance_id(building_type)
	if _is_route_using_placed_building(building_type):
		return "PLACED %s" % instance_id

	return "FALLBACK %s" % instance_id

func assign_building_route_for_adventurer(building_type: String, adventurer: Node, from_position: Vector2) -> Vector2:
	if adventurer == null:
		return _get_active_building_route_position(building_type)

	var instance_id := _select_best_building_instance_for_position(building_type, from_position)
	adventurer.set_meta(_get_route_meta_key(building_type), instance_id)
	last_selected_route_targets[building_type] = instance_id
	_update_active_route_visuals()
	return _get_building_route_position_for_instance(building_type, instance_id)

func get_route_position_for_adventurer(building_type: String, adventurer: Node) -> Vector2:
	if adventurer == null:
		return _get_active_building_route_position(building_type)

	var instance_id := _get_preferred_instance_id_for_adventurer(building_type, adventurer)
	return _get_building_route_position_for_instance(building_type, instance_id)

func _get_preferred_instance_id_for_adventurer(building_type: String, adventurer: Node) -> String:
	if adventurer == null:
		return _get_active_building_instance_id(building_type)

	var meta_key := _get_route_meta_key(building_type)

	if adventurer.has_meta(meta_key):
		var current_id := str(adventurer.get_meta(meta_key))
		if _is_building_instance_valid_for_type(building_type, current_id):
			return current_id

	return _select_and_store_best_building_instance(building_type, adventurer)

func _select_and_store_best_building_instance(building_type: String, adventurer: Node) -> String:
	var from_position := Vector2.ZERO
	if adventurer != null:
		from_position = adventurer.global_position

	var instance_id := _select_best_building_instance_for_position(building_type, from_position)

	if adventurer != null:
		adventurer.set_meta(_get_route_meta_key(building_type), instance_id)

	last_selected_route_targets[building_type] = instance_id
	return instance_id

func _select_best_building_instance_for_position(building_type: String, from_position: Vector2) -> String:
	var placed_buildings := _get_placed_buildings_of_type(building_type)

	if placed_buildings.is_empty():
		return _get_fallback_instance_id(building_type)

	var best_available_id := ""
	var best_available_distance := 99999999.0

	var best_fallback_id := ""
	var best_fallback_score := 99999999.0

	for building in placed_buildings:
		var building_control := building as ColorRect
		var instance_id := _ensure_building_instance_id(building_control)
		var route_position := building_control.global_position + building_control.size * 0.5
		var distance := from_position.distance_to(route_position)
		var occupants: Array = building_occupants.get(instance_id, [])
		var queue: Array = building_waiting_queues.get(instance_id, [])
		var has_open_capacity := occupants.size() < get_building_capacity_for_instance(building_type, instance_id)

		if has_open_capacity and distance < best_available_distance:
			best_available_distance = distance
			best_available_id = instance_id

		var pressure_score := float(occupants.size() + queue.size()) * 10000.0 + distance
		if pressure_score < best_fallback_score:
			best_fallback_score = pressure_score
			best_fallback_id = instance_id

	if best_available_id != "":
		return best_available_id

	return best_fallback_id

func _refresh_dynamic_route_markers() -> void:
	var old_store_id := str(active_building_instance_ids.get("general_store", ""))
	var old_inn_id := str(active_building_instance_ids.get("inn", ""))

	general_store_point.global_position = _get_active_building_route_position("general_store")
	inn_point.global_position = _get_active_building_route_position("inn")

	active_building_instance_ids["general_store"] = _get_active_building_instance_id("general_store")
	active_building_instance_ids["inn"] = _get_active_building_instance_id("inn")

	_cleanup_inactive_building_instance_state()
	_update_active_route_visuals()
	_notify_adventurers_routes_changed()

func _notify_adventurers_routes_changed() -> void:
	for adventurer in adventurers_container.get_children():
		if adventurer == null:
			continue

		var store_position := get_route_position_for_adventurer("general_store", adventurer)
		var inn_route_position := get_route_position_for_adventurer("inn", adventurer)

		var ai := adventurer.get_node_or_null("AdventurerAI")
		if ai != null and ai.has_method("update_town_route_positions"):
			ai.update_town_route_positions(
				store_position,
				inn_route_position,
				exit_to_world_point.global_position
			)



func _get_route_visual_position_for_type(building_type: String) -> Vector2:
	var last_id := str(last_selected_route_targets.get(building_type, ""))
	if last_id != "" and _is_building_instance_valid_for_type(building_type, last_id):
		return _get_building_route_position_for_instance(building_type, last_id)

	return _get_active_building_route_position(building_type)

func _create_queue_slot_visuals() -> void:
	_update_queue_slot_visuals()

func _update_queue_slot_visuals() -> void:
	_update_all_building_local_visuals()

func _update_all_building_local_visuals() -> void:
	for building in buildings_container.get_children():
		if not building is ColorRect:
			continue

		_update_local_building_visuals(building as ColorRect)

func _update_local_building_visuals(building: ColorRect) -> void:
	if building == null:
		return

	var building_type := str(building.get("building_id"))

	if not _is_queue_capable_building_type(building_type):
		_remove_local_queue_visuals(building)
		_update_placed_building_label(building)
		return

	_ensure_local_queue_visuals_for_building(building)
	_update_local_queue_visuals_for_building(building)
	_update_placed_building_label(building)

func _ensure_local_queue_visuals_for_building(building: ColorRect) -> void:
	if building == null:
		return

	var building_type := str(building.get("building_id"))
	var offsets := _get_queue_offsets(building_type)

	var queue_root := building.get_node_or_null("LocalQueueVisuals") as Control
	if queue_root == null:
		queue_root = Control.new()
		queue_root.name = "LocalQueueVisuals"
		queue_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_root.position = Vector2.ZERO
		queue_root.size = building.size
		queue_root.z_index = 92
		building.add_child(queue_root)

	queue_root.position = Vector2.ZERO
	queue_root.size = building.size

	var expected_count := offsets.size()
	var existing_count := queue_root.get_child_count()

	while existing_count < expected_count:
		var index := existing_count
		var slot_root := Control.new()
		slot_root.name = "LocalQueueSlot_%d" % (index + 1)
		slot_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_root.size = Vector2(38, 34)
		slot_root.z_index = 93
		queue_root.add_child(slot_root)

		var body := ColorRect.new()
		body.name = "QueueBody"
		body.mouse_filter = Control.MOUSE_FILTER_IGNORE
		body.size = LOCAL_QUEUE_SLOT_SIZE
		body.position = -LOCAL_QUEUE_SLOT_SIZE * 0.5
		body.color = Color(0.55, 0.55, 0.55, 0.20)
		slot_root.add_child(body)

		var label := Label.new()
		label.name = "QueueLabel"
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.position = Vector2(-18, 6)
		label.size = Vector2(36, 18)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = str(index + 1)
		slot_root.add_child(label)

		existing_count += 1

	while queue_root.get_child_count() > expected_count:
		var child := queue_root.get_child(queue_root.get_child_count() - 1)
		queue_root.remove_child(child)
		child.queue_free()

func _update_local_queue_visuals_for_building(building: ColorRect) -> void:
	if building == null:
		return

	var building_type := str(building.get("building_id"))
	var offsets := _get_queue_offsets(building_type)
	var instance_id := _get_building_instance_id_for_visuals(building)
	var queue_count := _get_queue_count_for_instance(instance_id)

	var queue_root := building.get_node_or_null("LocalQueueVisuals") as Control
	if queue_root == null:
		return

	queue_root.position = Vector2.ZERO
	queue_root.size = building.size

	for index in range(queue_root.get_child_count()):
		var slot_root := queue_root.get_child(index) as Control
		if slot_root == null:
			continue

		if index < offsets.size():
			slot_root.position = building.size * 0.5 + offsets[index]

		var body := slot_root.get_node_or_null("QueueBody") as ColorRect
		if body != null:
			if index < queue_count:
				body.color = Color(1.0, 0.35, 0.25, 0.70)
			else:
				body.color = Color(0.55, 0.55, 0.55, 0.20)

func _remove_local_queue_visuals(building: ColorRect) -> void:
	if building == null:
		return

	var queue_root := building.get_node_or_null("LocalQueueVisuals")
	if queue_root != null:
		building.remove_child(queue_root)
		queue_root.queue_free()

func _get_building_instance_id_for_visuals(building: ColorRect) -> String:
	if building == null:
		return ""

	var building_type := str(building.get("building_id"))

	if bool(building.get_meta("is_fixed_fallback", false)):
		return _get_fallback_instance_id(building_type)

	return _ensure_building_instance_id(building)

func _get_occupancy_count_for_instance(instance_id: String) -> int:
	_cleanup_building_occupants(instance_id)
	var occupants: Array = building_occupants.get(instance_id, [])
	return occupants.size()

func _get_queue_count_for_instance(instance_id: String) -> int:
	_cleanup_building_queue(instance_id)
	var queue: Array = building_waiting_queues.get(instance_id, [])
	return queue.size()


func get_service_seconds_for_adventurer(building_type: String, adventurer: Node, fallback_seconds: float = 1.0) -> float:
	if not _is_queue_capable_building_type(building_type):
		return fallback_seconds

	var instance_id := _get_active_building_instance_id(building_type)

	if adventurer != null:
		instance_id = _get_preferred_instance_id_for_adventurer(building_type, adventurer)

	return get_service_seconds_for_instance(building_type, instance_id)

func get_service_seconds_for_building(building: ColorRect) -> float:
	if building == null:
		return 1.0

	var building_type := str(building.get("building_id"))
	var worker_count := get_worker_count_for_building(building)
	var upgrade_level := get_upgrade_level_for_building(building)
	return _calculate_service_seconds(building_type, worker_count, upgrade_level)

func get_service_seconds_for_instance(building_type: String, instance_id: String) -> float:
	var worker_count := get_worker_count_for_instance(building_type, instance_id)
	var upgrade_level := get_upgrade_level_for_instance(building_type, instance_id)
	return _calculate_service_seconds(building_type, worker_count, upgrade_level)

func _calculate_service_seconds(building_type: String, worker_count: int, upgrade_level: int = 0) -> float:
	var base_seconds: float = float(BUILDING_BASE_SERVICE_SECONDS.get(building_type, 1.5))
	var worker_speed_multiplier: float = get_service_speed_multiplier_for_worker_count(worker_count)
	var upgrade_speed_bonus: float = float(maxi(upgrade_level, 0)) * UPGRADE_SERVICE_SPEED_BONUS_PER_LEVEL
	var speed_multiplier: float = worker_speed_multiplier + upgrade_speed_bonus
	return maxf(MIN_SERVICE_SECONDS, base_seconds / speed_multiplier)

func get_service_speed_multiplier_for_worker_count(worker_count: int) -> float:
	return 1.0 + float(maxi(worker_count, 0)) * WORKER_SPEED_BONUS_PER_WORKER

func get_worker_count_for_building(building: ColorRect) -> int:
	if building == null:
		return 0

	var building_type := str(building.get("building_id"))
	return int(building.get_meta("worker_count", _get_default_worker_count(building_type)))

func get_worker_count_for_instance(building_type: String, instance_id: String) -> int:
	if instance_id.begins_with("fallback_"):
		return _get_default_worker_count(building_type)

	var building := _get_building_by_instance_id(instance_id)
	if building == null:
		return _get_default_worker_count(building_type)

	return get_worker_count_for_building(building)

func _get_default_worker_count(building_type: String) -> int:
	return int(DEFAULT_WORKER_PLACEHOLDERS.get(building_type, 0))


func get_building_identity_summary(building_node: Node) -> String:
	if not building_node is ColorRect:
		return "No building selected."

	var building := building_node as ColorRect
	var building_type: String = str(building.get("building_id"))
	var display_name: String = _get_building_display_name(building_type)

	if bool(building.get_meta("is_fixed_fallback", false)):
		return "%s\nFixed fallback building\nProtected test/safety building" % display_name

	var instance_id: String = _ensure_building_instance_id(building)
	return "%s\nPlaced building\nID: %s" % [display_name, instance_id]

func get_building_capacity_queue_summary(building_node: Node) -> String:
	if not building_node is ColorRect:
		return "Capacity: -\nQueue: -"

	var building := building_node as ColorRect
	var building_type: String = str(building.get("building_id"))

	if not _is_queue_capable_building_type(building_type):
		return "Capacity: not used yet\nQueue: not used yet"

	var instance_id: String = _get_building_instance_id_for_visuals(building)
	var occupied_count: int = _get_occupancy_count_for_instance(instance_id)
	var capacity_count: int = get_building_capacity_for_building(building)
	var queue_count: int = _get_queue_count_for_instance(instance_id)

	return "Capacity: %d/%d occupied\nQueue: %d waiting" % [
		occupied_count,
		capacity_count,
		queue_count
	]

func get_building_worker_summary(building_node: Node) -> String:
	if not building_node is ColorRect:
		return "Workers: -"

	var building := building_node as ColorRect
	var building_type: String = str(building.get("building_id"))

	if not _is_queue_capable_building_type(building_type):
		return "Workers: not used yet"

	var worker_count: int = get_worker_count_for_building(building)
	var speed_multiplier: float = get_service_speed_multiplier_for_worker_count(worker_count)

	return "Workers: %d/%d\nWorker speed: x%.2f" % [
		worker_count,
		MAX_WORKER_PLACEHOLDER_COUNT,
		speed_multiplier
	]

func get_building_placement_summary(building_node: Node) -> String:
	if not building_node is ColorRect:
		return "Placement: -"

	var building := building_node as ColorRect

	if bool(building.get_meta("is_fixed_fallback", false)):
		return "Placement: fixed fallback\nMove/Demolish: disabled"

	return "Placement: player placed\nMove/Demolish: available"

func get_building_service_summary(building_node: Node) -> String:
	if not building_node is ColorRect:
		return "Service: -"

	var building := building_node as ColorRect
	var building_type := str(building.get("building_id"))

	if not _is_queue_capable_building_type(building_type):
		return "Service: no service controls yet."

	var worker_count := get_worker_count_for_building(building)
	var service_seconds := get_service_seconds_for_building(building)
	var speed_multiplier := get_service_speed_multiplier_for_worker_count(worker_count)
	var upgrade_level := get_upgrade_level_for_building(building)
	var upgrade_bonus: float = float(maxi(upgrade_level, 0)) * UPGRADE_SERVICE_SPEED_BONUS_PER_LEVEL
	var total_speed_multiplier: float = speed_multiplier + upgrade_bonus
	return "Service: %.1fs | Workers: %d/%d | Lv:%d | Speed: x%.2f" % [
		service_seconds,
		worker_count,
		MAX_WORKER_PLACEHOLDER_COUNT,
		upgrade_level,
		total_speed_multiplier
	]


func get_upgrade_level_for_building(building: ColorRect) -> int:
	if building == null:
		return 0

	return int(building.get_meta("upgrade_level", 0))

func get_upgrade_level_for_instance(building_type: String, instance_id: String) -> int:
	if instance_id.begins_with("fallback_"):
		return 0

	var building := _get_building_by_instance_id(instance_id)
	if building == null:
		return 0

	return get_upgrade_level_for_building(building)

func get_next_upgrade_cost_for_building(building: ColorRect) -> int:
	if building == null:
		return 0

	var building_type := str(building.get("building_id"))
	var current_level := get_upgrade_level_for_building(building)

	if current_level >= MAX_BUILDING_UPGRADE_LEVEL:
		return 0

	var base_cost := int(BUILDING_UPGRADE_BASE_COSTS.get(building_type, get_building_cost(building_type)))
	return base_cost * (current_level + 1)

func can_upgrade_building(building_node: Node) -> bool:
	if not building_node is ColorRect:
		return false

	var building := building_node as ColorRect

	if bool(building.get_meta("is_fixed_fallback", false)):
		return false

	if not bool(building.get_meta("is_placed_building", false)):
		return false

	return get_upgrade_level_for_building(building) < MAX_BUILDING_UPGRADE_LEVEL

func get_building_upgrade_summary(building_node: Node) -> String:
	if not building_node is ColorRect:
		return "Upgrade: -"

	var building := building_node as ColorRect
	var building_type := str(building.get("building_id"))
	var level := get_upgrade_level_for_building(building)

	if bool(building.get_meta("is_fixed_fallback", false)):
		return "Upgrade: fallback building cannot upgrade."

	if level >= MAX_BUILDING_UPGRADE_LEVEL:
		return "Upgrade: Lv %d/%d MAX" % [level, MAX_BUILDING_UPGRADE_LEVEL]

	var cost := get_next_upgrade_cost_for_building(building)
	var next_level := level + 1
	var capacity_now := get_building_capacity_for_building(building)
	var capacity_next := get_building_capacity_for_level(building_type, next_level)
	var service_now := get_service_seconds_for_building(building)
	var service_next := _calculate_service_seconds(building_type, get_worker_count_for_building(building), next_level)

	if _is_queue_capable_building_type(building_type):
		return "Upgrade: Lv %d/%d → %d | Cost %dg | Cap %d→%d | Svc %.1fs→%.1fs" % [
			level,
			MAX_BUILDING_UPGRADE_LEVEL,
			next_level,
			cost,
			capacity_now,
			capacity_next,
			service_now,
			service_next
		]

	return "Upgrade: Lv %d/%d → %d | Cost %dg | future effect placeholder" % [
		level,
		MAX_BUILDING_UPGRADE_LEVEL,
		next_level,
		cost
	]

func upgrade_building(building_node: Node) -> void:
	if not can_upgrade_building(building_node):
		_update_build_status("This building cannot be upgraded.")
		return

	var building := building_node as ColorRect
	var building_type := str(building.get("building_id"))
	var cost := get_next_upgrade_cost_for_building(building)

	if not GameState.spend_money(cost):
		_update_build_status("Not enough funds to upgrade %s. Need %dg, have %dg." % [
			_get_building_display_name(building_type),
			cost,
			GameState.money
		])
		show_town_floating_text("Need %dg" % cost, building.global_position + building.size * 0.5)
		return

	var new_level := get_upgrade_level_for_building(building) + 1
	building.set_meta("upgrade_level", new_level)

	_update_local_building_visuals(building)
	_update_active_route_visuals()
	save_placed_buildings_to_file(false)

	show_town_floating_text("Upgrade Lv %d" % new_level, building.global_position + building.size * 0.5)
	_update_build_status("Upgraded %s to Lv %d for %dg. Funds %dg." % [
		_get_building_display_name(building_type),
		new_level,
		cost,
		GameState.money
	])

func can_adjust_building_workers(building_node: Node) -> bool:
	if not building_node is ColorRect:
		return false

	var building := building_node as ColorRect
	return _is_queue_capable_building_type(str(building.get("building_id")))

func adjust_building_worker_count(building_node: Node, delta: int) -> void:
	if not can_adjust_building_workers(building_node):
		return

	var building := building_node as ColorRect
	var building_type := str(building.get("building_id"))
	var current_workers := get_worker_count_for_building(building)
	var new_workers := clampi(current_workers + delta, 0, MAX_WORKER_PLACEHOLDER_COUNT)
	building.set_meta("worker_count", new_workers)

	_update_local_building_visuals(building)
	_update_active_route_visuals()

	if bool(building.get_meta("is_placed_building", false)):
		save_placed_buildings_to_file(false)

	_update_build_status("%s workers set to %d. Service %.1fs." % [
		_get_building_display_name(building_type),
		new_workers,
		get_service_seconds_for_building(building)
	])

func _get_capacity_summary_for_building(building: ColorRect) -> String:
	if building == null:
		return ""

	var building_type := str(building.get("building_id"))
	if not _is_queue_capable_building_type(building_type):
		return ""

	var instance_id := _get_building_instance_id_for_visuals(building)
	return "%d/%d Q:%d\nLv:%d Svc:%.1fs W:%d" % [
		_get_occupancy_count_for_instance(instance_id),
		get_building_capacity_for_building(building),
		_get_queue_count_for_instance(instance_id),
		get_upgrade_level_for_building(building),
		get_service_seconds_for_building(building),
		get_worker_count_for_building(building)
	]

func _is_queue_capable_building_type(building_type: String) -> bool:
	return building_type == "general_store" or building_type == "inn"

func _create_active_route_visuals() -> void:
	active_store_route_visual = _create_route_visual("ActiveStoreRoute", "ACTIVE STORE ROUTE", Color(0.95, 0.85, 0.25, 0.60))
	active_inn_route_visual = _create_route_visual("ActiveInnRoute", "ACTIVE INN ROUTE", Color(0.55, 0.40, 1.0, 0.55))

func _create_route_visual(node_name: String, label_text: String, marker_color: Color) -> Node2D:
	var route_root := Node2D.new()
	route_root.name = node_name
	route_root.z_index = 9
	add_child(route_root)

	var body := ColorRect.new()
	body.name = "RouteBody"
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.position = Vector2(-45, -14)
	body.size = Vector2(90, 28)
	body.color = marker_color
	route_root.add_child(body)

	var label := Label.new()
	label.name = "RouteLabel"
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.position = Vector2(-95, -60)
	label.size = Vector2(190, 58)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = label_text
	route_root.add_child(label)

	return route_root

func _update_active_route_visuals() -> void:
	if active_store_route_visual != null:
		active_store_route_visual.global_position = _get_route_visual_position_for_type("general_store")
		var store_label := active_store_route_visual.get_node_or_null("RouteLabel") as Label
		if store_label != null:
			store_label.text = "ACTIVE STORE\n%s\n%s" % [_get_active_route_source_text("general_store"), get_building_capacity_summary("general_store")]

	if active_inn_route_visual != null:
		active_inn_route_visual.global_position = _get_route_visual_position_for_type("inn")
		var inn_label := active_inn_route_visual.get_node_or_null("RouteLabel") as Label
		if inn_label != null:
			inn_label.text = "ACTIVE INN\n%s\n%s" % [_get_active_route_source_text("inn"), get_building_capacity_summary("inn")]

	_update_queue_slot_visuals()

func _update_placed_building_label(building: ColorRect) -> void:
	if building == null:
		return

	var label := building.get_node_or_null("BuildingLabel") as Label
	if label == null:
		label = building.get_node_or_null("Label") as Label

	if label == null:
		return

	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var building_type := str(building.get("building_id"))
	var display_name := _get_building_display_name(building_type)

	if bool(building.get_meta("is_fixed_fallback", false)):
		if _is_queue_capable_building_type(building_type):
			label.text = "%s\n(Fixed Test)\n%s" % [display_name, _get_capacity_summary_for_building(building)]
		else:
			label.text = "%s\n(Fixed Test)" % display_name
		return

	var instance_id := _ensure_building_instance_id(building)
	if _is_queue_capable_building_type(building_type):
		label.text = "%s\n%s\n%s" % [display_name, instance_id, _get_capacity_summary_for_building(building)]
	else:
		label.text = "%s\n%s" % [display_name, instance_id]

func _get_building_size(building_type: String) -> Vector2:
	match building_type:
		"guild_hall":
			return Vector2(200, 100)
		"inn":
			return Vector2(175, 90)
		"general_store":
			return Vector2(210, 90)
		_:
			return Vector2(160, 90)

func _get_building_color(building_type: String) -> Color:
	match building_type:
		"guild_hall":
			return Color(0.36, 0.24, 0.16, 1.0)
		"inn":
			return Color(0.28, 0.18, 0.38, 1.0)
		"general_store":
			return Color(0.42, 0.32, 0.12, 1.0)
		_:
			return Color(0.4, 0.4, 0.4, 1.0)

func _get_building_display_name(building_type: String) -> String:
	match building_type:
		"guild_hall":
			return "Guild Hall"
		"inn":
			return "Inn"
		"general_store":
			return "General Store"
		_:
			return "Building"

func _update_build_status(message: String) -> void:
	if build_status_label != null:
		build_status_label.text = message

func _create_entrance_exit_visuals() -> void:
	_create_gate_visual("TownEntranceVisual", town_entrance.global_position, "TOWN ENTRANCE", Color(0.2, 0.65, 1.0, 0.6))
	_create_gate_visual("WorldExitVisual", exit_to_world_point.global_position, "WORLD EXIT", Color(1.0, 0.65, 0.2, 0.6))

func _create_gate_visual(node_name: String, marker_position: Vector2, label_text: String, gate_color: Color) -> void:
	var gate_root := Node2D.new()
	gate_root.name = node_name
	gate_root.z_index = 8
	add_child(gate_root)

	var gate_body := ColorRect.new()
	gate_body.name = "GateBody"
	gate_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gate_body.position = marker_position - Vector2(58, 20)
	gate_body.size = Vector2(116, 40)
	gate_body.color = gate_color
	gate_root.add_child(gate_body)

	var gate_label := Label.new()
	gate_label.name = "GateLabel"
	gate_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gate_label.position = marker_position - Vector2(80, 56)
	gate_label.size = Vector2(160, 30)
	gate_label.text = label_text
	gate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gate_root.add_child(gate_label)

	var arrow_label := Label.new()
	arrow_label.name = "ArrowLabel"
	arrow_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrow_label.position = marker_position - Vector2(20, 10)
	arrow_label.size = Vector2(40, 30)
	arrow_label.text = "↓"
	arrow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gate_root.add_child(arrow_label)
