extends Node2D

const ADVENTURER_SCENE: PackedScene = preload("res://scenes/adventurers/Adventurer.tscn")
const CLICKABLE_BUILDING_SCRIPT: Script = preload("res://scripts/buildings/ClickableBuilding.gd")

const GRID_SIZE := 16.0
const BUILDABLE_RECT := Rect2(Vector2(140, 90), Vector2(1000, 490))
const PLACEMENT_PADDING := 10.0
const ENTRANCE_EXIT_CLEARANCE_SIZE := Vector2(150, 100)

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
var is_checking_returned_travelers: bool = false

var active_building_type: String = ""
var build_action: String = "place"
var selected_building: ColorRect = null
var moving_building: ColorRect = null
var selected_outline: ColorRect = null
var build_ghost: ColorRect = null
var build_ghost_label: Label = null
var build_panel: PanelContainer = null
var build_status_label: Label = null
var buildable_area_overlay: ColorRect = null

func _ready() -> void:
	print("Town scene loaded.")
	GameState.state_changed.connect(_on_game_state_changed)
	_register_existing_buildings()
	_mark_fixed_fallback_buildings()
	_create_build_panel()
	_create_entrance_exit_visuals()
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
	var adventurer := ADVENTURER_SCENE.instantiate()
	adventurers_container.add_child(adventurer)

	var spawn_offset := Vector2((spawn_count % 8) * 24, -floori(float(spawn_count) / 8.0) * 24)
	var queue_offset := Vector2((spawn_count % 4) * 18, floori(float(spawn_count) / 4.0) * 12)

	var entrance_position := town_entrance.global_position + spawn_offset
	var shop_position := general_store_point.global_position + queue_offset
	var exit_position := exit_to_world_point.global_position + Vector2(0, spawn_offset.y)

	adventurer.global_position = entrance_position

	if adventurer.has_method("setup_placeholder"):
		adventurer.setup_placeholder(_generate_adventurer_name(), "fighter", 1)

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
	var adventurer := ADVENTURER_SCENE.instantiate()
	adventurers_container.add_child(adventurer)

	var return_offset := Vector2((return_spawn_count % 5) * 22, -floori(float(return_spawn_count) / 5.0) * 22)
	var spawn_position := exit_to_world_point.global_position + Vector2(-65, -20) + return_offset
	var shop_position := general_store_point.global_position + Vector2((return_spawn_count % 4) * 18, 24 + floori(float(return_spawn_count) / 4.0) * 12)
	var inn_position := inn_point.global_position + Vector2((return_spawn_count % 4) * 18, 24 + floori(float(return_spawn_count) / 4.0) * 12)
	var exit_position := exit_to_world_point.global_position + Vector2(0, return_offset.y)

	adventurer.global_position = spawn_position

	if adventurer.has_method("setup_from_traveler_data"):
		adventurer.setup_from_traveler_data(traveler_data)

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

		var label := building.get_node_or_null("Label") as Label
		if label == null:
			label = building.get_node_or_null("BuildingLabel") as Label

		if label != null and not label.text.contains("Fixed"):
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
		building_menu.open_for_building(building_id)

func _create_build_panel() -> void:
	build_panel = PanelContainer.new()
	build_panel.name = "BuildPanel"
	build_panel.position = Vector2(930, 12)
	build_panel.size = Vector2(290, 230)
	build_panel.custom_minimum_size = Vector2(290, 230)
	build_panel.z_index = 100
	build_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(build_panel)

	var vbox := VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	build_panel.add_child(vbox)

	var title_label := Label.new()
	title_label.text = "Build Mode"
	vbox.add_child(title_label)

	var note_label := Label.new()
	note_label.text = "Select a building, move ghost, left-click to place, right-click to cancel."
	note_label.autowrap_mode = 3
	vbox.add_child(note_label)

	var guild_button := Button.new()
	guild_button.text = "Build Guild Hall"
	guild_button.focus_mode = Control.FOCUS_NONE
	guild_button.pressed.connect(_on_build_button_pressed.bind("guild_hall"))
	vbox.add_child(guild_button)

	var inn_button := Button.new()
	inn_button.text = "Build Inn"
	inn_button.focus_mode = Control.FOCUS_NONE
	inn_button.pressed.connect(_on_build_button_pressed.bind("inn"))
	vbox.add_child(inn_button)

	var store_button := Button.new()
	store_button.text = "Build General Store"
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

	var cancel_button := Button.new()
	cancel_button.text = "Cancel Build / Move"
	cancel_button.focus_mode = Control.FOCUS_NONE
	cancel_button.pressed.connect(cancel_build_mode)
	vbox.add_child(cancel_button)

	build_status_label = Label.new()
	build_status_label.text = "Build status: inactive"
	build_status_label.autowrap_mode = 3
	vbox.add_child(build_status_label)

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
	_update_build_status("Placing %s" % _get_building_display_name(active_building_type))
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
		build_ghost_label.text = "%s\nValid" % _get_building_display_name(active_building_type)
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
		_place_building(active_building_type, placement_rect)
		_update_build_status("Placed %s." % _get_building_display_name(active_building_type))
	cancel_build_mode()

func _place_building(building_type: String, placement_rect: Rect2) -> void:
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

	buildings_container.add_child(building)

	var label := Label.new()
	label.name = "BuildingLabel"
	label.text = _get_building_display_name(building_type)
	label.position = Vector2(10, placement_rect.size.y * 0.5 - 12)
	label.size = Vector2(placement_rect.size.x - 20, 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	building.add_child(label)

	if building.has_signal("building_clicked"):
		building.connect("building_clicked", Callable(self, "_on_building_clicked"))


func select_building(building: ColorRect) -> void:
	selected_building = building
	_update_selected_outline()

	if bool(building.get_meta("is_fixed_fallback", false)):
		_update_build_status("Selected %s. Fixed fallback is protected." % _get_building_display_name(str(building.get("building_id"))))
	else:
		_update_build_status("Selected %s. You can move or demolish it." % _get_building_display_name(str(building.get("building_id"))))

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
	_update_build_status("Moving %s. Left-click valid area to confirm, right-click to cancel." % _get_building_display_name(active_building_type))
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
	_update_build_status("Moved %s." % _get_building_display_name(active_building_type))

func _on_demolish_selected_button_pressed() -> void:
	if selected_building == null:
		_update_build_status("Select a placed building first.")
		return

	if bool(selected_building.get_meta("is_fixed_fallback", false)):
		_update_build_status("Fixed fallback buildings are protected for now.")
		return

	var demolished_name := _get_building_display_name(str(selected_building.get("building_id")))
	var building_to_remove := selected_building
	clear_selected_building()
	building_to_remove.queue_free()
	_update_build_status("Demolished %s." % demolished_name)

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
