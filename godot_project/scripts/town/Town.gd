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

const GAMEPLAY_VIEWPORT_WIDTH := 1280.0
const SIDEBAR_WIDTH := 320.0
const SIDEBAR_MARGIN := 10.0
const SIDEBAR_TOP := 12.0
const SIDEBAR_HEIGHT := 696.0

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
var sidebar_panel: PanelContainer = null
var sidebar_content: VBoxContainer = null
var sidebar_mode_title_label: Label = null
var sidebar_body: VBoxContainer = null
var sidebar_modes: Dictionary = {}
var sidebar_mode_buttons: Dictionary = {}
var active_sidebar_mode: String = ""
var building_details_holder: Control = null
var build_menu_holder: Control = null
var economy_holder: Control = null
var economy_scroll: ScrollContainer = null
var economy_content: VBoxContainer = null
var economy_summary_label: Label = null
var save_holder: Control = null
var save_status_label: Label = null
var save_slot_label: Label = null
var save_slot_timestamp_label: Label = null
var save_slot_summary_label: Label = null
var save_overwrite_placeholder_label: Label = null
var save_clear_slot_placeholder_label: Label = null
var save_autosave_status_label: Label = null
var save_slot_buttons: Dictionary = {}

var esc_main_menu_overlay: Control = null
var esc_main_menu_panel: PanelContainer = null
var esc_main_menu_title_label: Label = null
var esc_main_menu_body_label: Label = null
var esc_main_menu_active_tab: String = "save_load"
var debug_placeholder_holder: Control = null

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
	if GameState.has_method("load_economy_history_from_file"):
		GameState.load_economy_history_from_file(false)
	if GameClock.has_signal("day_started") and not GameClock.day_started.is_connected(_on_game_clock_day_started):
		GameClock.day_started.connect(_on_game_clock_day_started)
	_register_existing_buildings()
	_create_esc_main_menu_overlay()
	_mark_fixed_fallback_buildings()
	load_placed_buildings_from_file(false)
	_create_sidebar_manager()
	_create_build_panel()
	_dock_build_panel_in_sidebar()
	_dock_building_details_in_sidebar()
	_create_entrance_exit_visuals()
	_create_active_route_visuals()
	_create_queue_slot_visuals()
	_refresh_dynamic_route_markers()
	_check_for_returned_travelers()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_esc_main_menu()
		get_viewport().set_input_as_handled()

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
	if sidebar_panel != null and _control_contains_global_point(sidebar_panel, mouse_position):
		return true

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

func _refresh_build_menu_funds_text() -> void:
	if build_panel_root_container == null:
		return

	for child in build_panel_root_container.get_children():
		if child is Label and str(child.text).begins_with("Funds:"):
			var label := child as Label
			label.text = "Funds: %dg\nChoose a building, then place it in the town.\nLeft-click valid ground to confirm. Right-click to cancel." % GameState.money
			return

func _on_game_clock_day_started(day_number: int) -> void:
	if GameState.has_method("ensure_economy_bucket_for_day"):
		GameState.ensure_economy_bucket_for_day(day_number)
	if GameState.has_method("save_economy_history_to_file"):
		GameState.save_economy_history_to_file(false)
	_request_autosave("new_day_%d" % day_number)
	_refresh_economy_sidebar()

func _on_game_state_changed() -> void:
	_refresh_build_menu_funds_text()
	_refresh_economy_sidebar()
	if active_sidebar_mode == "save_manager":
		_refresh_save_manager_panel()
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

	open_sidebar_mode("building_details")

	if building_menu != null and building_menu.has_method("open_for_building"):
		building_menu.open_for_building(building_id, building_node, self)


func _create_sidebar_manager() -> void:
	sidebar_panel = PanelContainer.new()
	sidebar_panel.name = "RightSidebar"
	sidebar_panel.position = Vector2(GAMEPLAY_VIEWPORT_WIDTH + SIDEBAR_MARGIN, SIDEBAR_TOP)
	sidebar_panel.size = Vector2(SIDEBAR_WIDTH - SIDEBAR_MARGIN * 2.0, SIDEBAR_HEIGHT)
	sidebar_panel.custom_minimum_size = Vector2(SIDEBAR_WIDTH - SIDEBAR_MARGIN * 2.0, SIDEBAR_HEIGHT)
	sidebar_panel.z_index = 120
	sidebar_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(sidebar_panel)

	sidebar_content = VBoxContainer.new()
	sidebar_content.name = "SidebarContent"
	sidebar_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar_panel.add_child(sidebar_content)

	var mode_button_row := HBoxContainer.new()
	mode_button_row.name = "SidebarModeButtons"
	mode_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_content.add_child(mode_button_row)

	_create_sidebar_mode_button(mode_button_row, "building_details", "Details")
	_create_sidebar_mode_button(mode_button_row, "build_menu", "Build")
	_create_sidebar_mode_button(mode_button_row, "economy", "Economy")
	_create_sidebar_mode_button(mode_button_row, "save_manager", "Save")
	_create_sidebar_mode_button(mode_button_row, "debug_placeholder", "Debug")

	sidebar_mode_title_label = Label.new()
	sidebar_mode_title_label.name = "SidebarModeTitle"
	sidebar_mode_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sidebar_mode_title_label.text = "Sidebar"
	sidebar_content.add_child(sidebar_mode_title_label)

	sidebar_body = VBoxContainer.new()
	sidebar_body.name = "SidebarBody"
	sidebar_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar_content.add_child(sidebar_body)

	building_details_holder = _create_sidebar_holder("BuildingDetailsHolder")
	sidebar_body.add_child(building_details_holder)
	sidebar_modes["building_details"] = building_details_holder

	build_menu_holder = _create_sidebar_holder("BuildMenuHolder")
	sidebar_body.add_child(build_menu_holder)
	sidebar_modes["build_menu"] = build_menu_holder

	economy_holder = _create_sidebar_holder("EconomyHolder")
	sidebar_body.add_child(economy_holder)
	sidebar_modes["economy"] = economy_holder
	_populate_economy_placeholder()

	save_holder = _create_sidebar_holder("SaveManagerHolder")
	sidebar_body.add_child(save_holder)
	sidebar_modes["save_manager"] = save_holder
	_populate_save_manager_panel()

	debug_placeholder_holder = _create_sidebar_holder("DebugPlaceholderHolder")
	sidebar_body.add_child(debug_placeholder_holder)
	sidebar_modes["debug_placeholder"] = debug_placeholder_holder
	_populate_debug_placeholder()

	open_sidebar_mode("build_menu")

func _create_sidebar_mode_button(parent: Control, mode_id: String, button_text: String) -> void:
	var button := Button.new()
	button.name = "%sButton" % mode_id.capitalize()
	button.text = button_text
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func() -> void:
		open_sidebar_mode(mode_id)
	)
	parent.add_child(button)
	sidebar_mode_buttons[mode_id] = button

func _create_sidebar_holder(holder_name: String) -> Control:
	var holder := VBoxContainer.new()
	holder.name = holder_name
	holder.visible = false
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.custom_minimum_size = Vector2(SIDEBAR_WIDTH - SIDEBAR_MARGIN * 2.0 - 24.0, 0.0)
	return holder



func _create_esc_main_menu_overlay() -> void:
	esc_main_menu_overlay = Control.new()
	esc_main_menu_overlay.name = "EscMainMenuOverlay"
	esc_main_menu_overlay.visible = false
	esc_main_menu_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	esc_main_menu_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(esc_main_menu_overlay)

	var dim_background := ColorRect.new()
	dim_background.name = "DimBackground"
	dim_background.color = Color(0, 0, 0, 0.55)
	dim_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	esc_main_menu_overlay.add_child(dim_background)

	esc_main_menu_panel = PanelContainer.new()
	esc_main_menu_panel.name = "EscMainMenuPanel"
	esc_main_menu_panel.offset_left = 350.0
	esc_main_menu_panel.offset_top = 100.0
	esc_main_menu_panel.offset_right = 930.0
	esc_main_menu_panel.offset_bottom = 620.0
	esc_main_menu_overlay.add_child(esc_main_menu_panel)

	var root_vbox := VBoxContainer.new()
	root_vbox.name = "EscMainMenuRootVBox"
	root_vbox.add_theme_constant_override("separation", 8)
	esc_main_menu_panel.add_child(root_vbox)

	esc_main_menu_title_label = Label.new()
	esc_main_menu_title_label.name = "EscMainMenuTitleLabel"
	esc_main_menu_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	esc_main_menu_title_label.text = "Dungeon Frontier Guild-Town"
	root_vbox.add_child(esc_main_menu_title_label)

	var top_button_row := HBoxContainer.new()
	top_button_row.name = "EscMainMenuTopButtonRow"
	top_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(top_button_row)

	_create_esc_menu_button(top_button_row, "Resume", "Return to the current game.", _on_esc_resume_pressed)
	_create_esc_menu_button(top_button_row, "Save / Load", "Open save/load information placeholder.", func() -> void: _set_esc_main_menu_tab("save_load"))
	_create_esc_menu_button(top_button_row, "Settings", "Open general settings placeholder.", func() -> void: _set_esc_main_menu_tab("settings"))
	_create_esc_menu_button(top_button_row, "Quit", "Quit placeholder. Export builds will later route this safely.", _on_esc_quit_placeholder_pressed)

	var settings_button_row := HBoxContainer.new()
	settings_button_row.name = "EscSettingsButtonRow"
	settings_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(settings_button_row)

	_create_esc_menu_button(settings_button_row, "Graphics", "Graphics settings placeholder.", func() -> void: _set_esc_main_menu_tab("graphics"))
	_create_esc_menu_button(settings_button_row, "Audio", "Audio settings placeholder.", func() -> void: _set_esc_main_menu_tab("audio"))
	_create_esc_menu_button(settings_button_row, "Controls", "Control settings placeholder.", func() -> void: _set_esc_main_menu_tab("controls"))

	esc_main_menu_body_label = Label.new()
	esc_main_menu_body_label.name = "EscMainMenuBodyLabel"
	esc_main_menu_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	esc_main_menu_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	esc_main_menu_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(esc_main_menu_body_label)

	_refresh_esc_main_menu_body()

func _create_esc_menu_button(parent: Control, text: String, tooltip: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.tooltip_text = tooltip
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	parent.add_child(button)

func _toggle_esc_main_menu() -> void:
	if esc_main_menu_overlay == null:
		return

	esc_main_menu_overlay.visible = not esc_main_menu_overlay.visible

	if esc_main_menu_overlay.visible:
		_refresh_esc_main_menu_body()

func _on_esc_resume_pressed() -> void:
	if esc_main_menu_overlay != null:
		esc_main_menu_overlay.visible = false

func _on_esc_quit_placeholder_pressed() -> void:
	_set_esc_main_menu_tab("quit")

func _set_esc_main_menu_tab(tab_id: String) -> void:
	esc_main_menu_active_tab = tab_id
	_refresh_esc_main_menu_body()

func _refresh_esc_main_menu_body() -> void:
	if esc_main_menu_body_label == null:
		return

	var save_summary := "SaveManager unavailable."
	var autosave_summary := "Autosave unavailable."
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null:
		if save_manager.has_method("get_active_slot_label_text"):
			save_summary = str(save_manager.get_active_slot_label_text())
		if save_manager.has_method("get_autosave_status_text"):
			autosave_summary = str(save_manager.get_autosave_status_text())

	match esc_main_menu_active_tab:
		"save_load":
			esc_main_menu_body_label.text = "SAVE / LOAD PLACEHOLDER\n\nCurrent Manual Slot:\n%s\n\n%s\n\nFuture main menu flow:\n- Continue loads the autosave.\n- New starts a new save state.\n- Load opens manual save slot selection.\n- Settings opens graphics/audio/controls.\n- Quit exits safely.\n\nFor now, use the sidebar Save tab for actual Save All / Load All testing." % [
				save_summary,
				autosave_summary
			]
		"settings":
			esc_main_menu_body_label.text = "SETTINGS PLACEHOLDER\n\nFuture settings categories:\n- Graphics\n- Audio\n- Controls\n- Accessibility\n- Gameplay/UI preferences\n\nThis overlay will eventually hold deeper settings so the sidebar can stay focused on quick management actions."
		"graphics":
			esc_main_menu_body_label.text = "GRAPHICS PLACEHOLDER\n\nFuture options:\n- Window mode\n- Resolution\n- Pixel scaling\n- UI scale\n- VSync\n- Visual effects intensity"
		"audio":
			esc_main_menu_body_label.text = "AUDIO PLACEHOLDER\n\nFuture options:\n- Master volume\n- Music volume\n- SFX volume\n- UI sounds\n- Mute options"
		"controls":
			esc_main_menu_body_label.text = "CONTROLS PLACEHOLDER\n\nFuture options:\n- Rebind controls\n- Camera movement\n- Build mode shortcuts\n- Pause/menu controls\n- Tooltip delay"
		"quit":
			esc_main_menu_body_label.text = "QUIT PLACEHOLDER\n\nQuit is intentionally not destructive yet.\n\nFuture behavior:\n- Warn about unsaved manual changes.\n- Offer Save and Quit.\n- Return to title menu.\n- Exit game from exported builds."
		_:
			esc_main_menu_body_label.text = "MAIN MENU PLACEHOLDER"


func _populate_save_manager_panel() -> void:
	if save_holder == null:
		return

	var slot_button_row := HBoxContainer.new()
	slot_button_row.name = "SaveSlotButtonRow"
	slot_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(slot_button_row)

	_create_save_slot_button(slot_button_row, 1)
	_create_save_slot_button(slot_button_row, 2)
	_create_save_slot_button(slot_button_row, 3)

	save_slot_label = Label.new()
	save_slot_label.name = "SaveSlotLabel"
	save_slot_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_slot_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_slot_label)

	save_slot_timestamp_label = Label.new()
	save_slot_timestamp_label.name = "SaveSlotTimestampLabel"
	save_slot_timestamp_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_slot_timestamp_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_slot_timestamp_label)

	save_slot_summary_label = Label.new()
	save_slot_summary_label.name = "SaveSlotSummaryLabel"
	save_slot_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_slot_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_slot_summary_label)

	save_autosave_status_label = Label.new()
	save_autosave_status_label.name = "SaveAutosaveStatusLabel"
	save_autosave_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_autosave_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_autosave_status_label)

	var button_row := HBoxContainer.new()
	button_row.name = "SaveAllLoadAllRow"
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(button_row)

	var save_all_button := Button.new()
	save_all_button.name = "SaveAllButton"
	save_all_button.text = "Save All"
	save_all_button.tooltip_text = "Save a manual snapshot to the selected slot."
	save_all_button.focus_mode = Control.FOCUS_NONE
	save_all_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_all_button.pressed.connect(_on_save_all_pressed)
	button_row.add_child(save_all_button)

	var load_all_button := Button.new()
	load_all_button.name = "LoadAllButton"
	load_all_button.text = "Load All"
	load_all_button.tooltip_text = "Load the selected manual save slot."
	load_all_button.focus_mode = Control.FOCUS_NONE
	load_all_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_all_button.pressed.connect(_on_load_all_pressed)
	button_row.add_child(load_all_button)

	var slot_options_row := HBoxContainer.new()
	slot_options_row.name = "SaveSlotOptionsRow"
	slot_options_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(slot_options_row)

	var confirm_overwrite_button := Button.new()
	confirm_overwrite_button.name = "ConfirmOverwritePlaceholderButton"
	confirm_overwrite_button.text = "Arm Overwrite"
	confirm_overwrite_button.tooltip_text = "Arm overwrite protection for the selected occupied manual slot."
	confirm_overwrite_button.focus_mode = Control.FOCUS_NONE
	confirm_overwrite_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	confirm_overwrite_button.pressed.connect(_on_confirm_overwrite_placeholder_pressed)
	slot_options_row.add_child(confirm_overwrite_button)

	var clear_slot_button := Button.new()
	clear_slot_button.name = "ClearSlotPlaceholderButton"
	clear_slot_button.text = "Clear Slot"
	clear_slot_button.tooltip_text = "Press twice to clear the selected manual slot."
	clear_slot_button.focus_mode = Control.FOCUS_NONE
	clear_slot_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clear_slot_button.pressed.connect(_on_clear_slot_placeholder_pressed)
	slot_options_row.add_child(clear_slot_button)

	save_overwrite_placeholder_label = Label.new()
	save_overwrite_placeholder_label.name = "SaveOverwritePlaceholderLabel"
	save_overwrite_placeholder_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_overwrite_placeholder_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_overwrite_placeholder_label)

	save_clear_slot_placeholder_label = Label.new()
	save_clear_slot_placeholder_label.name = "SaveClearSlotPlaceholderLabel"
	save_clear_slot_placeholder_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_clear_slot_placeholder_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_clear_slot_placeholder_label)

	var manual_note := Label.new()
	manual_note.name = "SaveManualNote"
	manual_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	manual_note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	manual_note.text = "Save All targets the selected manual slot. Autosave writes to its own safety slot and never overwrites manual slots. If the selected manual slot is occupied, press Arm Overwrite before Save All. Clear Slot requires pressing Clear Slot twice.\n\nThis snapshot is separate from live auto-save files, so later placement/demolition should not overwrite it.\n\nCurrently includes:\n- Core state: gold, inventory, policies\n- Building layout\n- Economy history\n- Active town adventurers\n- World travelers/state\n\nFuture hooks:\n- Settings"
	save_holder.add_child(manual_note)

	save_status_label = Label.new()
	save_status_label.name = "SaveStatusLabel"
	save_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_status_label)

	_refresh_save_manager_panel("Ready.")


func _create_save_slot_button(parent: Control, slot_number: int) -> void:
	var button := Button.new()
	button.name = "SaveSlot%dButton" % slot_number
	button.text = "Slot %d" % slot_number
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = "Switch to manual save Slot %d." % slot_number
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(_on_save_slot_button_pressed.bind(slot_number))
	parent.add_child(button)
	save_slot_buttons[slot_number] = button

func _on_save_slot_button_pressed(slot_number: int) -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null or not save_manager.has_method("set_active_slot"):
		_refresh_save_manager_panel("SaveManager slot switching unavailable.")
		return

	var switched: bool = bool(save_manager.set_active_slot(slot_number))
	if switched:
		_refresh_save_slot_buttons(save_manager)
		_refresh_save_manager_panel("Active save slot changed to Slot %d." % slot_number)
	else:
		_refresh_save_manager_panel("Failed to switch to Slot %d." % slot_number)

func _refresh_save_slot_buttons(save_manager: Node) -> void:
	if save_manager == null or not save_manager.has_method("get_active_slot_number"):
		return

	var active_number: int = int(save_manager.get_active_slot_number())

	for slot_number in save_slot_buttons.keys():
		var button := save_slot_buttons[slot_number] as Button
		if button == null:
			continue

		var slot_int: int = int(slot_number)
		button.disabled = false
		button.text = "Slot %d%s" % [
			slot_int,
			" *" if slot_int == active_number else ""
		]

func _on_confirm_overwrite_placeholder_pressed() -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null or not save_manager.has_method("request_overwrite_confirmation"):
		_refresh_save_manager_panel("Overwrite confirmation unavailable.")
		return

	var armed: bool = bool(save_manager.request_overwrite_confirmation())
	_refresh_save_manager_panel("Overwrite armed. Press Save All to overwrite Slot 1." if armed else "Slot is empty. Overwrite confirmation not needed.")

func _on_clear_slot_placeholder_pressed() -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null or not save_manager.has_method("request_clear_slot_confirmation"):
		_refresh_save_manager_panel("Clear slot confirmation unavailable.")
		return

	var message: String = str(save_manager.request_clear_slot_confirmation())
	_refresh_save_manager_panel(message)

func get_autosave_policy_status_text() -> String:
	return "Autosave Policy: daily only\nAutosave runs at new day boundary. Manual slots are still player-controlled."

func _request_autosave(reason: String) -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null or not save_manager.has_method("autosave_all"):
		return

	save_manager.autosave_all(self, reason, false)

	if active_sidebar_mode == "save_manager":
		_refresh_save_manager_panel("Autosaved: %s" % reason)

func _on_save_all_pressed() -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null or not save_manager.has_method("save_all"):
		_refresh_save_manager_panel("SaveManager unavailable.")
		return

	var success: bool = bool(save_manager.save_all(self, true))
	_refresh_save_manager_panel("Save All complete." if success else "Save All failed or partial.")
	show_town_floating_text("Save All" if success else "Save Failed", Vector2(620, 120))

func _on_load_all_pressed() -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null or not save_manager.has_method("load_all"):
		_refresh_save_manager_panel("SaveManager unavailable.")
		return

	var success: bool = bool(save_manager.load_all(self, true))
	_refresh_dynamic_route_markers()
	_refresh_economy_sidebar()
	_refresh_save_manager_panel("Load All complete." if success else "Load All partial or no save found.")
	show_town_floating_text("Load All" if success else "Load Partial", Vector2(620, 120))

func _refresh_save_manager_panel(extra_message: String = "") -> void:
	if save_status_label == null:
		return

	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null:
		save_status_label.text = "SAVE STATUS\nSaveManager unavailable."
		return

	_refresh_save_slot_buttons(save_manager)

	if save_slot_label != null and save_manager.has_method("get_active_slot_label_text"):
		save_slot_label.text = "SAVE SLOT\n%s" % str(save_manager.get_active_slot_label_text())

	if save_slot_timestamp_label != null and save_manager.has_method("get_active_slot_timestamp_text"):
		save_slot_timestamp_label.text = str(save_manager.get_active_slot_timestamp_text())

	if save_slot_summary_label != null and save_manager.has_method("get_active_slot_summary_text"):
		save_slot_summary_label.text = str(save_manager.get_active_slot_summary_text())

	if save_autosave_status_label != null and save_manager.has_method("get_autosave_status_text"):
		save_autosave_status_label.text = str(save_manager.get_autosave_status_text())

	if save_overwrite_placeholder_label != null and save_manager.has_method("get_overwrite_confirmation_placeholder_text"):
		save_overwrite_placeholder_label.text = str(save_manager.get_overwrite_confirmation_placeholder_text())

	if save_clear_slot_placeholder_label != null and save_manager.has_method("get_clear_slot_placeholder_text"):
		save_clear_slot_placeholder_label.text = str(save_manager.get_clear_slot_placeholder_text())

	var summary_text := "SaveManager summary unavailable."
	if save_manager.has_method("get_save_manager_summary"):
		summary_text = str(save_manager.get_save_manager_summary())

	var last_save_text := "No save result."
	if save_manager.has_method("get_last_save_status_text"):
		last_save_text = str(save_manager.get_last_save_status_text())

	var last_load_text := "No load result."
	if save_manager.has_method("get_last_load_status_text"):
		last_load_text = str(save_manager.get_last_load_status_text())

	var core_status_text := "Core state unavailable."
	if GameState.has_method("get_core_state_status_text"):
		core_status_text = GameState.get_core_state_status_text()

	var adventurer_status_text := "Adventurer status unavailable."
	if has_method("get_adventurer_roster_status_text"):
		adventurer_status_text = get_adventurer_roster_status_text()

	var world_status_text := "World status unavailable."
	if GameState.has_method("get_world_state_status_text"):
		world_status_text = GameState.get_world_state_status_text()

	var autosave_policy_text := get_autosave_policy_status_text()

	save_status_label.text = "SAVE STATUS\n%s\n\n%s\n\n%s\n\nCORE STATE\n%s\n\nADVENTURERS\n%s\n\nWORLD\n%s\n\nLAST SAVE\n%s\n\nLAST LOAD\n%s" % [
		extra_message,
		summary_text,
		autosave_policy_text,
		core_status_text,
		adventurer_status_text,
		world_status_text,
		last_save_text,
		last_load_text
	]

func _populate_debug_placeholder() -> void:
	if debug_placeholder_holder == null:
		return

	var label := Label.new()
	label.name = "DebugPlaceholderLabel"
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size = Vector2(SIDEBAR_WIDTH - SIDEBAR_MARGIN * 2.0 - 36.0, 0.0)
	label.text = "DEBUG PLACEHOLDER\n\nThe old Debug overlay still works from the top-left Show Debug button.\n\nThis sidebar mode is reserved for a future migration of debug tools into the right sidebar."
	debug_placeholder_holder.add_child(label)


func _populate_economy_placeholder() -> void:
	if economy_holder == null:
		return

	var button_row := HBoxContainer.new()
	button_row.name = "EconomyButtonRow"
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	economy_holder.add_child(button_row)

	var refresh_button := Button.new()
	refresh_button.name = "RefreshEconomyButton"
	refresh_button.text = "Refresh"
	refresh_button.focus_mode = Control.FOCUS_NONE
	refresh_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	refresh_button.pressed.connect(_refresh_economy_sidebar)
	button_row.add_child(refresh_button)

	var reset_button := Button.new()
	reset_button.name = "ResetEconomyTotalsButton"
	reset_button.text = "Reset Totals"
	reset_button.focus_mode = Control.FOCUS_NONE
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset_button.pressed.connect(_on_reset_economy_totals_pressed)
	button_row.add_child(reset_button)

	var save_load_row := HBoxContainer.new()
	save_load_row.name = "EconomySaveLoadRow"
	save_load_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	economy_holder.add_child(save_load_row)

	var save_button := Button.new()
	save_button.name = "SaveEconomyHistoryButton"
	save_button.text = "Save History"
	save_button.focus_mode = Control.FOCUS_NONE
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button.pressed.connect(_on_save_economy_history_pressed)
	save_load_row.add_child(save_button)

	var load_button := Button.new()
	load_button.name = "LoadEconomyHistoryButton"
	load_button.text = "Load History"
	load_button.focus_mode = Control.FOCUS_NONE
	load_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_button.pressed.connect(_on_load_economy_history_pressed)
	save_load_row.add_child(load_button)

	economy_scroll = ScrollContainer.new()
	economy_scroll.name = "EconomyScroll"
	economy_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	economy_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	economy_scroll.custom_minimum_size = Vector2(SIDEBAR_WIDTH - SIDEBAR_MARGIN * 2.0 - 36.0, 560.0)
	economy_holder.add_child(economy_scroll)

	economy_content = VBoxContainer.new()
	economy_content.name = "EconomyContent"
	economy_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	economy_scroll.add_child(economy_content)

	economy_summary_label = Label.new()
	economy_summary_label.name = "EconomySummaryLabel"
	economy_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	economy_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	economy_summary_label.custom_minimum_size = Vector2(SIDEBAR_WIDTH - SIDEBAR_MARGIN * 2.0 - 52.0, 0.0)
	economy_content.add_child(economy_summary_label)

	_refresh_economy_sidebar()

func _on_reset_economy_totals_pressed() -> void:
	if GameState.has_method("reset_economy_event_totals"):
		GameState.reset_economy_event_totals()
	_refresh_economy_sidebar()

func _on_save_economy_history_pressed() -> void:
	if GameState.has_method("save_economy_history_to_file"):
		GameState.save_economy_history_to_file(true)
	_refresh_economy_sidebar()

func _on_load_economy_history_pressed() -> void:
	if GameState.has_method("load_economy_history_from_file"):
		GameState.load_economy_history_from_file(true)
	_refresh_economy_sidebar()

func _refresh_economy_sidebar() -> void:
	if economy_summary_label == null:
		return

	economy_summary_label.text = _get_economy_sidebar_text()

func _get_economy_sidebar_text() -> String:
	var small_potions: int = 0
	var slime_gel: int = 0

	if GameState.has_method("get_item_count"):
		small_potions = GameState.get_item_count("small_potion")
		slime_gel = GameState.get_item_count("slime_gel")

	var current_day: int = GameState.get_current_economy_day_number()
	var previous_day: int = GameState.get_previous_day_number()
	var day_bucket: Dictionary = GameState.get_current_day_economy_bucket()
	var previous_bucket: Dictionary = GameState.get_previous_day_economy_bucket()

	var day_shop_income: int = int(day_bucket.get("shop_sales_income", 0))
	var day_shop_sales_count: int = int(day_bucket.get("shop_sales_count", 0))
	var day_inn_income: int = int(day_bucket.get("inn_income", 0))
	var day_inn_visit_count: int = int(day_bucket.get("inn_visit_count", 0))
	var day_material_outflow: int = int(day_bucket.get("material_purchase_outflow", 0))
	var day_material_count: int = int(day_bucket.get("material_purchase_count", 0))
	var day_construction_outflow: int = int(day_bucket.get("building_construction_outflow", 0))
	var day_construction_count: int = int(day_bucket.get("building_construction_count", 0))
	var day_upgrade_outflow: int = int(day_bucket.get("upgrade_outflow", 0))
	var day_upgrade_count: int = int(day_bucket.get("upgrade_count", 0))
	var day_income_total: int = GameState.get_current_day_income_total()
	var day_outflow_total: int = GameState.get_current_day_outflow_total()
	var day_net: int = GameState.get_current_day_net_total()

	var previous_income_total: int = GameState.get_bucket_income_total(previous_bucket)
	var previous_outflow_total: int = GameState.get_bucket_outflow_total(previous_bucket)
	var previous_net: int = GameState.get_bucket_net_total(previous_bucket)
	var previous_shop_income: int = int(previous_bucket.get("shop_sales_income", 0))
	var previous_inn_income: int = int(previous_bucket.get("inn_income", 0))
	var previous_material_outflow: int = int(previous_bucket.get("material_purchase_outflow", 0))

	var net_trend: String = GameState.get_trend_direction_text(day_net, previous_net, true)
	var income_trend: String = GameState.get_trend_direction_text(day_income_total, previous_income_total, true)
	var outflow_trend: String = GameState.get_trend_direction_text(day_outflow_total, previous_outflow_total, false)

	var shop_income: int = GameState.economy_shop_sales_income
	var shop_sales_count: int = GameState.economy_shop_sales_count
	var inn_income: int = GameState.economy_inn_income
	var inn_visit_count: int = GameState.economy_inn_visit_count
	var material_outflow: int = GameState.economy_material_purchase_outflow
	var material_purchase_count: int = GameState.economy_material_purchase_count
	var construction_outflow: int = GameState.economy_building_construction_outflow
	var construction_count: int = GameState.economy_building_construction_count
	var upgrade_outflow: int = GameState.economy_upgrade_outflow
	var upgrade_count: int = GameState.economy_upgrade_count
	var tracked_income: int = GameState.get_tracked_income_total()
	var tracked_outflow: int = GameState.get_tracked_outflow_total()
	var tracked_net: int = GameState.get_tracked_net_total()

	return "ECONOMY TRENDS\n\nCurrent Gold: %dg\nSave: SaveManager / economy_history.json\n\nCURRENT DAY: Day %d\nDay Net: %dg (%s vs prev)\nDay Income: %dg (%s)\n  Shop Sales: %dg / %d sale(s)\n  Inn Income: %dg / %d visit(s)\nDay Outflow: %dg (%s)\n  Materials: %dg / %d item(s)\n  Construction: %dg / %d build(s)\n  Upgrades: %dg / %d upgrade(s)\n\nPREVIOUS DAY: Day %d\nPrev Net: %dg\nPrev Income: %dg\n  Shop Income: %dg\n  Inn Income: %dg\nPrev Outflow: %dg\n  Material Outflow: %dg\n\nSESSION TOTALS\nSession Net: %dg\nSession Income: %dg\n  Shop Sales: %dg / %d sale(s)\n  Inn Income: %dg / %d visit(s)\nSession Outflow: %dg\n  Materials: %dg / %d item(s)\n  Construction: %dg / %d build(s)\n  Upgrades: %dg / %d upgrade(s)\n\nCURRENT STOCK SNAPSHOT\nSmall Potions: %d\nSlime Gel: %d\n\nNOTES\nEconomy history now saves/loads. Trends are simple current-day vs previous-day comparisons." % [
		GameState.money,
		current_day,
		day_net,
		net_trend,
		day_income_total,
		income_trend,
		day_shop_income,
		day_shop_sales_count,
		day_inn_income,
		day_inn_visit_count,
		day_outflow_total,
		outflow_trend,
		day_material_outflow,
		day_material_count,
		day_construction_outflow,
		day_construction_count,
		day_upgrade_outflow,
		day_upgrade_count,
		previous_day,
		previous_net,
		previous_income_total,
		previous_shop_income,
		previous_inn_income,
		previous_outflow_total,
		previous_material_outflow,
		tracked_net,
		tracked_income,
		shop_income,
		shop_sales_count,
		inn_income,
		inn_visit_count,
		tracked_outflow,
		material_outflow,
		material_purchase_count,
		construction_outflow,
		construction_count,
		upgrade_outflow,
		upgrade_count,
		small_potions,
		slime_gel
	]

func open_sidebar_mode(mode_id: String) -> void:
	if sidebar_modes.is_empty():
		return

	active_sidebar_mode = mode_id

	for key in sidebar_modes.keys():
		var holder := sidebar_modes[key] as Control
		if holder != null:
			holder.visible = key == mode_id

	for key in sidebar_mode_buttons.keys():
		var button := sidebar_mode_buttons[key] as Button
		if button != null:
			button.disabled = key == mode_id

	if sidebar_mode_title_label != null:
		match mode_id:
			"building_details":
				sidebar_mode_title_label.text = "Building Details"
			"build_menu":
				sidebar_mode_title_label.text = "Build Menu"
			"economy":
				sidebar_mode_title_label.text = "Economy Trends"
				_refresh_economy_sidebar()
			"save_manager":
				sidebar_mode_title_label.text = "Save / Load"
				_refresh_save_manager_panel()
			"debug_placeholder":
				sidebar_mode_title_label.text = "Debug"
			_:
				sidebar_mode_title_label.text = "Sidebar"

	if building_menu != null:
		building_menu.visible = mode_id == "building_details" and building_menu.current_building_id != ""

func _dock_build_panel_in_sidebar() -> void:
	if build_panel == null or build_menu_holder == null:
		return

	if build_panel.get_parent() != null:
		build_panel.get_parent().remove_child(build_panel)

	build_menu_holder.add_child(build_panel)
	build_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	build_panel.offset_left = 0.0
	build_panel.offset_top = 0.0
	build_panel.offset_right = 0.0
	build_panel.offset_bottom = 0.0
	build_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	build_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	build_panel.visible = true

func _dock_building_details_in_sidebar() -> void:
	if building_menu == null or building_details_holder == null:
		return

	if building_menu.get_parent() != null:
		building_menu.get_parent().remove_child(building_menu)

	building_details_holder.add_child(building_menu)
	building_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	building_menu.offset_left = 0.0
	building_menu.offset_top = 0.0
	building_menu.offset_right = 0.0
	building_menu.offset_bottom = 0.0
	building_menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	building_menu.size_flags_vertical = Control.SIZE_EXPAND_FILL
	building_menu.visible = false

	if building_menu.has_method("set_embedded_in_sidebar"):
		building_menu.set_embedded_in_sidebar(true)

func _create_build_panel() -> void:
	build_panel = PanelContainer.new()
	build_panel.name = "BuildPanel"
	build_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	build_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	build_panel.custom_minimum_size = Vector2(0, 0)
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
	build_panel_collapse_button.text = "Build Options"
	build_panel_collapse_button.focus_mode = Control.FOCUS_NONE
	build_panel_collapse_button.disabled = true
	build_panel_collapse_button.visible = false
	vbox.add_child(build_panel_collapse_button)

	var title_label := Label.new()
	title_label.text = "BUILD MENU"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)

	var note_label := Label.new()
	note_label.name = "BuildFundsInstructionLabel"
	note_label.text = "Funds: %dg\nChoose a building, then place it in town.\nLeft-click valid ground to confirm. Right-click to cancel." % GameState.money
	note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(note_label)

	var civic_category_label := Label.new()
	civic_category_label.text = "CIVIC"
	vbox.add_child(civic_category_label)

	var guild_button := Button.new()
	guild_button.text = "Guild Hall - %dg" % get_building_cost("guild_hall")
	guild_button.focus_mode = Control.FOCUS_NONE
	guild_button.pressed.connect(_on_build_button_pressed.bind("guild_hall"))
	vbox.add_child(guild_button)

	var service_category_label := Label.new()
	service_category_label.text = "SERVICES"
	vbox.add_child(service_category_label)

	var inn_button := Button.new()
	inn_button.text = "Inn - %dg" % get_building_cost("inn")
	inn_button.focus_mode = Control.FOCUS_NONE
	inn_button.pressed.connect(_on_build_button_pressed.bind("inn"))
	vbox.add_child(inn_button)

	var store_button := Button.new()
	store_button.text = "General Store - %dg" % get_building_cost("general_store")
	store_button.focus_mode = Control.FOCUS_NONE
	store_button.pressed.connect(_on_build_button_pressed.bind("general_store"))
	vbox.add_child(store_button)

	var move_button := Button.new()
	move_button.text = "Move Selected Building"
	move_button.focus_mode = Control.FOCUS_NONE
	move_button.pressed.connect(_on_move_selected_button_pressed)
	vbox.add_child(move_button)

	var demolish_button := Button.new()
	demolish_button.text = "Demolish Selected Building"
	demolish_button.focus_mode = Control.FOCUS_NONE
	demolish_button.pressed.connect(_on_demolish_selected_button_pressed)
	vbox.add_child(demolish_button)

	var save_button := Button.new()
	save_button.text = "Save Building Layout"
	save_button.focus_mode = Control.FOCUS_NONE
	save_button.pressed.connect(_on_save_buildings_button_pressed)
	vbox.add_child(save_button)

	var load_button := Button.new()
	load_button.text = "Load Building Layout"
	load_button.focus_mode = Control.FOCUS_NONE
	load_button.pressed.connect(_on_load_buildings_button_pressed)
	vbox.add_child(load_button)

	var cancel_button := Button.new()
	cancel_button.text = "Cancel Placement / Move"
	cancel_button.focus_mode = Control.FOCUS_NONE
	cancel_button.pressed.connect(cancel_build_mode)
	vbox.add_child(cancel_button)

	build_status_label = Label.new()
	build_status_label.text = "Build status: inactive"
	build_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(build_status_label)

func _on_toggle_build_panel_collapsed() -> void:
	# Collapse behavior is intentionally disabled now that Build Menu lives inside sidebar modes.
	build_panel_collapsed = false

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

		GameState.record_building_construction_outflow(building_cost, active_building_type)
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


func get_adventurer_roster_save_data() -> Dictionary:
	var saved_adventurers: Array[Dictionary] = []

	for child in adventurers_container.get_children():
		if child == null:
			continue

		if child.has_method("get_adventurer_save_data"):
			saved_adventurers.append(child.get_adventurer_save_data())

	return {
		"version": 1,
		"saved_day": GameClock.day_number,
		"saved_phase": GameClock.get_phase_name(),
		"adventurers": saved_adventurers
	}

func apply_adventurer_roster_save_data(save_data: Dictionary, show_feedback: bool = false) -> bool:
	if save_data.is_empty():
		if show_feedback:
			_update_build_status("Adventurer roster save data is empty.")
		return false

	var saved_adventurers: Array = save_data.get("adventurers", [])

	_clear_active_town_adventurers_for_load()

	var index: int = 0
	for adventurer_data in saved_adventurers:
		if not adventurer_data is Dictionary:
			continue

		_spawn_saved_adventurer_from_data(adventurer_data, index)
		index += 1

	if show_feedback:
		_update_build_status("Loaded %d saved adventurer(s)." % index)

	_refresh_save_manager_panel()
	return true

func _spawn_saved_adventurer_from_data(adventurer_data: Dictionary, index: int) -> void:
	_refresh_dynamic_route_markers()

	var adventurer := ADVENTURER_SCENE.instantiate()
	adventurers_container.add_child(adventurer)

	var default_offset := Vector2((index % 6) * 22, floori(float(index) / 6.0) * 22)
	var default_position := town_entrance.global_position + Vector2(45, 35) + default_offset
	adventurer.global_position = default_position

	if adventurer.has_method("setup_from_adventurer_save_data"):
		adventurer.setup_from_adventurer_save_data(adventurer_data)
	elif adventurer.has_method("setup_placeholder"):
		adventurer.setup_placeholder(str(adventurer_data.get("display_name", "Saved")), str(adventurer_data.get("class_id", "fighter")), int(adventurer_data.get("level", 1)))

	_resume_loaded_adventurer_town_routine(adventurer, index)
	GameState.register_adventurer(adventurer)

func _resume_loaded_adventurer_town_routine(adventurer: Node, index: int) -> void:
	if adventurer == null:
		return

	var queue_offset := Vector2((index % 4) * 18, 24 + floori(float(index) / 4.0) * 12)
	var spawn_position: Vector2 = adventurer.global_position
	var exit_position: Vector2 = exit_to_world_point.global_position + Vector2(0, queue_offset.y)
	var shop_position: Vector2 = assign_building_route_for_adventurer("general_store", adventurer, spawn_position) + queue_offset
	var inn_position: Vector2 = assign_building_route_for_adventurer("inn", adventurer, spawn_position) + queue_offset

	var saved_state: String = str(adventurer.get("saved_resume_state")) if adventurer.get("saved_resume_state") != null else "Idle"
	var slime_gel_count: int = 0
	if adventurer.has_method("get_item_count"):
		slime_gel_count = int(adventurer.get_item_count(GameState.SLIME_GEL_ID))

	var has_loot_to_sell: bool = slime_gel_count > 0
	var should_resume_return_flow: bool = saved_state in [
		"ReturnedToTown",
		"GoToGeneralStoreToSell",
		"WaitForGeneralStoreSellCapacity",
		"SellSlimeGel",
		"SoldLoot",
        "SaleBlockedMaterialBuyingOff"
	]

	var ai_node: Node = adventurer.get("ai") if adventurer.get("ai") != null else null
	if ai_node != null and ai_node.has_method("update_town_route_positions"):
		ai_node.update_town_route_positions(shop_position, inn_position, exit_position)

	if should_resume_return_flow and has_loot_to_sell and adventurer.has_method("start_return_to_town_routine"):
		if adventurer.has_method("set_purchase_message"):
			adventurer.set_purchase_message("Loaded. Resuming loot return.")
		adventurer.start_return_to_town_routine(spawn_position, shop_position, inn_position, exit_position)
		return

	if should_resume_return_flow and not has_loot_to_sell:
		if adventurer.has_method("set_purchase_message"):
			adventurer.set_purchase_message("Loaded. No loot to sell; leaving again.")

		if ai_node != null and ai_node.has_method("set_state"):
			if adventurer.has_method("needs_inn_rest") and adventurer.needs_inn_rest():
				ai_node.set_state("GoToInn")
			else:
				ai_node.set_state("GoToExitForNextTrip")
			return

	if saved_state in ["GoToExit", "LeavingTown", "GoToExitForNextTrip"]:
		if adventurer.has_method("set_purchase_message"):
			adventurer.set_purchase_message("Loaded. Continuing toward exit.")
		if ai_node != null and ai_node.has_method("set_state"):
			ai_node.set_state("GoToExitForNextTrip")
			return

	if saved_state == "MaxTripsReached":
		if adventurer.has_method("set_purchase_message"):
			adventurer.set_purchase_message("Loaded. Max trips reached.")
		if ai_node != null and ai_node.has_method("set_state"):
			ai_node.set_state("MaxTripsReached")
			return

	if adventurer.has_method("set_purchase_message"):
		adventurer.set_purchase_message("Loaded. Resuming town routine.")

	if adventurer.has_method("start_town_routine"):
		adventurer.start_town_routine(spawn_position, shop_position, exit_position)

func _clear_active_town_adventurers_for_load() -> void:
	var current_adventurers := adventurers_container.get_children()

	for adventurer in current_adventurers:
		if adventurer == null:
			continue

		if has_method("release_all_building_capacity_for_adventurer"):
			release_all_building_capacity_for_adventurer(adventurer)

		if GameState.has_method("unregister_adventurer"):
			GameState.unregister_adventurer(adventurer)

		adventurers_container.remove_child(adventurer)
		adventurer.queue_free()

	_reset_building_capacity()

func get_adventurer_roster_status_text() -> String:
	var active_count: int = 0
	var resident_count: int = 0
	var visitor_count: int = 0

	for child in adventurers_container.get_children():
		if child == null:
			continue

		active_count += 1
		var role_text: String = str(child.get("roster_role")) if child.get("roster_role") != null else "visitor"

		if role_text == "resident_placeholder":
			resident_count += 1
		else:
			visitor_count += 1

	return "Active town adventurers: %d\\nVisitors: %d\\nResidents placeholder: %d\\nSaved fields: name, class, level, gold, HP, energy, inventory, visitor/resident flag." % [
		active_count,
		visitor_count,
		resident_count
	]

func get_building_layout_save_data() -> Dictionary:
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

	return {
		"version": BUILDING_SAVE_VERSION,
		"next_building_instance_number": next_building_instance_number,
		"placed_buildings": placed_buildings_data
	}

func save_placed_buildings_to_file(show_feedback: bool = true) -> void:
	var save_data: Dictionary = get_building_layout_save_data()
	var placed_buildings_data: Array = save_data.get("placed_buildings", [])

	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null or not save_manager.has_method("save_building_layout_data"):
		var error_text := "Building save failed. SaveManager unavailable."
		_update_build_status(error_text)
		if show_feedback:
			show_town_floating_text("Save Failed", Vector2(620, 120))
		return

	var success: bool = bool(save_manager.save_building_layout_data(save_data, show_feedback))
	if not success:
		_update_build_status("Building save failed through SaveManager.")
		if show_feedback:
			show_town_floating_text("Save Failed", Vector2(620, 120))
		return

	if show_feedback:
		_update_build_status("Saved %d placed building(s) through live layout save." % placed_buildings_data.size())
		show_town_floating_text("Buildings Saved", Vector2(620, 120))

func load_placed_buildings_from_file(show_feedback: bool = true) -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null or not save_manager.has_method("load_building_layout_data"):
		if show_feedback:
			_update_build_status("Building load failed. SaveManager unavailable.")
			show_town_floating_text("Load Failed", Vector2(620, 120))
		return

	var save_data: Dictionary = save_manager.load_building_layout_data(show_feedback)
	if save_data.is_empty():
		if show_feedback:
			_update_build_status("No building save found yet.")
			show_town_floating_text("No Save Found", Vector2(620, 120))
		return

	var loaded: bool = apply_building_layout_save_data(save_data, show_feedback)

	if loaded and show_feedback:
		var placed_buildings_data: Array = save_data.get("placed_buildings", [])
		_update_build_status("Loaded %d placed building(s) through live layout save." % placed_buildings_data.size())
		show_town_floating_text("Buildings Loaded", Vector2(620, 120))

func apply_building_layout_save_data(save_data: Dictionary, show_feedback: bool = false) -> bool:
	if save_data.is_empty():
		if show_feedback:
			_update_build_status("Building save data is empty.")
		return false

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
	_update_all_building_local_visuals()

	if show_feedback:
		_update_build_status("Applied %d placed building(s)." % placed_buildings_data.size())

	return true

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

	GameState.record_upgrade_outflow(cost, building_type)

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
