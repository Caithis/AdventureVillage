extends Node2D

const FLOATING_TEXT_SCENE: PackedScene = preload("res://scenes/ui/FloatingText.tscn")

const GAMEPLAY_VIEWPORT_WIDTH := 1280.0
const SIDEBAR_WIDTH := 320.0
const SIDEBAR_MARGIN := 10.0
const SIDEBAR_TOP := 12.0
const SIDEBAR_HEIGHT := 696.0

@onready var world_travelers_container: Node2D = $WorldTravelers
@onready var slimes_container: Node2D = $Slimes

var traveler_markers: Dictionary = {}
var slime_markers: Dictionary = {}
var last_traveler_event_logs: Dictionary = {}
var last_slime_event_logs: Dictionary = {}

var sidebar_panel: PanelContainer = null
var sidebar_content: VBoxContainer = null
var sidebar_mode_title_label: Label = null
var sidebar_body: VBoxContainer = null
var sidebar_modes: Dictionary = {}
var sidebar_mode_buttons: Dictionary = {}
var active_sidebar_mode: String = ""
var world_info_holder: Control = null
var save_holder: Control = null
var debug_holder: Control = null
var world_info_label: Label = null
var save_status_label: Label = null
var save_slot_label: Label = null
var save_slot_timestamp_label: Label = null
var save_slot_summary_label: Label = null
var save_autosave_status_label: Label = null
var save_slot_buttons: Dictionary = {}
var debug_sidebar_label: Label = null
var debug_sidebar_scroll: ScrollContainer = null

var esc_main_menu_overlay: Control = null
var esc_main_menu_panel: PanelContainer = null
var esc_submenu_panel: PanelContainer = null
var esc_main_menu_title_label: Label = null
var esc_submenu_title_label: Label = null
var esc_submenu_body_label: Label = null
var esc_main_menu_active_tab: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("World Map scene loaded.")
	GameState.state_changed.connect(_refresh_world_state)
	if GameClock.has_signal("time_updated") and not GameClock.time_updated.is_connected(_on_world_time_updated):
		GameClock.time_updated.connect(_on_world_time_updated)
	_create_world_sidebar()
	_create_esc_main_menu_overlay()
	_refresh_world_state()

func _process(_delta: float) -> void:
	if GameState.has_method("is_simulation_paused") and GameState.is_simulation_paused():
		return

	_update_marker_positions_and_labels()
	_update_slime_positions_and_labels()

func _is_active_input_scene() -> bool:
	return visible and SceneRouter.current_view_name == SceneRouter.WORLD_MAP_VIEW_NAME

func _unhandled_input(event: InputEvent) -> void:
	if not _is_active_input_scene():
		return

	if event.is_action_pressed("ui_cancel"):
		_toggle_esc_main_menu()
		get_viewport().set_input_as_handled()

func _exit_tree() -> void:
	if GameState.has_method("set_simulation_paused"):
		GameState.set_simulation_paused(false)
	if get_tree() != null:
		get_tree().paused = false

	if GameState.state_changed.is_connected(_refresh_world_state):
		GameState.state_changed.disconnect(_refresh_world_state)
	if GameClock.has_signal("time_updated") and GameClock.time_updated.is_connected(_on_world_time_updated):
		GameClock.time_updated.disconnect(_on_world_time_updated)


func _on_world_time_updated(_day_number: int, _phase_name: String, _time_remaining: float, _phase_progress: float) -> void:
	_refresh_world_sidebar_labels()

func _create_world_sidebar() -> void:
	sidebar_panel = PanelContainer.new()
	sidebar_panel.name = "WorldRightSidebar"
	sidebar_panel.position = Vector2(GAMEPLAY_VIEWPORT_WIDTH + SIDEBAR_MARGIN, SIDEBAR_TOP)
	sidebar_panel.size = Vector2(SIDEBAR_WIDTH - SIDEBAR_MARGIN * 2.0, SIDEBAR_HEIGHT)
	sidebar_panel.custom_minimum_size = Vector2(SIDEBAR_WIDTH - SIDEBAR_MARGIN * 2.0, SIDEBAR_HEIGHT)
	sidebar_panel.z_index = 120
	sidebar_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(sidebar_panel)

	sidebar_content = VBoxContainer.new()
	sidebar_content.name = "WorldSidebarContent"
	sidebar_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar_panel.add_child(sidebar_content)

	var mode_button_row := HBoxContainer.new()
	mode_button_row.name = "WorldSidebarModeButtons"
	mode_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_content.add_child(mode_button_row)

	_create_sidebar_mode_button(mode_button_row, "world_info", "World")
	_create_sidebar_mode_button(mode_button_row, "save_manager", "Save")
	_create_sidebar_mode_button(mode_button_row, "debug", "Debug")

	sidebar_mode_title_label = Label.new()
	sidebar_mode_title_label.name = "WorldSidebarModeTitle"
	sidebar_mode_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sidebar_mode_title_label.text = "World"
	sidebar_content.add_child(sidebar_mode_title_label)

	sidebar_body = VBoxContainer.new()
	sidebar_body.name = "WorldSidebarBody"
	sidebar_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar_content.add_child(sidebar_body)

	world_info_holder = _create_sidebar_holder("WorldInfoHolder")
	sidebar_body.add_child(world_info_holder)
	sidebar_modes["world_info"] = world_info_holder
	_populate_world_info_panel()

	save_holder = _create_sidebar_holder("WorldSaveHolder")
	sidebar_body.add_child(save_holder)
	sidebar_modes["save_manager"] = save_holder
	_populate_world_save_panel()

	debug_holder = _create_sidebar_holder("WorldDebugHolder")
	sidebar_body.add_child(debug_holder)
	sidebar_modes["debug"] = debug_holder
	_populate_world_debug_panel()

	_open_sidebar_mode("world_info")

func _create_sidebar_mode_button(parent: Control, mode_id: String, text: String) -> void:
	var button := Button.new()
	button.text = text
	button.tooltip_text = "Open %s panel." % text
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func() -> void:
		_open_sidebar_mode(mode_id)
	)
	parent.add_child(button)
	sidebar_mode_buttons[mode_id] = button

func _create_sidebar_holder(holder_name: String) -> VBoxContainer:
	var holder := VBoxContainer.new()
	holder.name = holder_name
	holder.visible = false
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.custom_minimum_size = Vector2(SIDEBAR_WIDTH - SIDEBAR_MARGIN * 2.0 - 24.0, 0.0)
	return holder

func _open_sidebar_mode(mode_id: String) -> void:
	active_sidebar_mode = mode_id

	for key in sidebar_modes.keys():
		var holder := sidebar_modes[key] as Control
		if holder != null:
			holder.visible = key == mode_id

	for key in sidebar_mode_buttons.keys():
		var button := sidebar_mode_buttons[key] as Button
		if button != null:
			button.disabled = key == mode_id

	match mode_id:
		"world_info":
			sidebar_mode_title_label.text = "World Map"
			_refresh_world_info_panel()
		"save_manager":
			sidebar_mode_title_label.text = "Save / Load"
			_refresh_world_save_panel()
		"debug":
			sidebar_mode_title_label.text = "Debug"
			_refresh_world_debug_panel()
		_:
			sidebar_mode_title_label.text = "Sidebar"

func _populate_world_info_panel() -> void:
	var return_button := Button.new()
	return_button.text = "Return to Town"
	return_button.tooltip_text = "Switch back to the persistent Town view."
	return_button.focus_mode = Control.FOCUS_NONE
	return_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return_button.pressed.connect(_on_return_to_town_pressed)
	world_info_holder.add_child(return_button)

	world_info_label = Label.new()
	world_info_label.name = "WorldInfoLabel"
	world_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	world_info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	world_info_holder.add_child(world_info_label)

func _populate_world_save_panel() -> void:
	var slot_button_row := HBoxContainer.new()
	slot_button_row.name = "WorldSaveSlotButtonRow"
	slot_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(slot_button_row)

	_create_save_slot_button(slot_button_row, 1)
	_create_save_slot_button(slot_button_row, 2)
	_create_save_slot_button(slot_button_row, 3)

	save_slot_label = Label.new()
	save_slot_label.name = "WorldSaveSlotLabel"
	save_slot_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_slot_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_slot_label)

	save_slot_timestamp_label = Label.new()
	save_slot_timestamp_label.name = "WorldSaveSlotTimestampLabel"
	save_slot_timestamp_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_slot_timestamp_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_slot_timestamp_label)

	save_slot_summary_label = Label.new()
	save_slot_summary_label.name = "WorldSaveSlotSummaryLabel"
	save_slot_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_slot_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_slot_summary_label)

	save_autosave_status_label = Label.new()
	save_autosave_status_label.name = "WorldSaveAutosaveStatusLabel"
	save_autosave_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_autosave_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_autosave_status_label)

	var save_row := HBoxContainer.new()
	save_row.name = "WorldSaveButtonRow"
	save_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_row)

	var save_button := Button.new()
	save_button.text = "Save All"
	save_button.tooltip_text = "Save selected manual slot. Uses persistent Town data even while viewing World Map."
	save_button.focus_mode = Control.FOCUS_NONE
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button.pressed.connect(_on_world_save_all_pressed)
	save_row.add_child(save_button)

	var load_button := Button.new()
	load_button.text = "Load All"
	load_button.tooltip_text = "Load selected manual slot."
	load_button.focus_mode = Control.FOCUS_NONE
	load_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_button.pressed.connect(_on_world_load_all_pressed)
	save_row.add_child(load_button)

	save_status_label = Label.new()
	save_status_label.name = "WorldSaveStatusLabel"
	save_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_holder.add_child(save_status_label)

func _create_save_slot_button(parent: Control, slot_number: int) -> void:
	var button := Button.new()
	button.name = "WorldSaveSlot%dButton" % slot_number
	button.text = "Slot %d" % slot_number
	button.tooltip_text = "Switch to manual save Slot %d." % slot_number
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(_on_world_save_slot_button_pressed.bind(slot_number))
	parent.add_child(button)
	save_slot_buttons[slot_number] = button

func _populate_world_debug_panel() -> void:
	var button_row := HBoxContainer.new()
	button_row.name = "WorldDebugButtonRow"
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	debug_holder.add_child(button_row)

	_create_world_debug_button(button_row, "Town", "Return to Town view.", _on_return_to_town_pressed)
	_create_world_debug_button(button_row, "+Gold", "Add 25 gold for testing.", _on_world_debug_add_money_pressed)
	_create_world_debug_button(button_row, "+Gel", "Add 1 Slime Gel for testing.", _on_world_debug_add_slime_gel_pressed)

	var button_row_2 := HBoxContainer.new()
	button_row_2.name = "WorldDebugButtonRow2"
	button_row_2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	debug_holder.add_child(button_row_2)

	_create_world_debug_button(button_row_2, "Nest+", "Grow slime nest by 1.", _on_world_debug_grow_slime_nest_pressed)
	_create_world_debug_button(button_row_2, "Spawn", "Spawn one town adventurer.", _on_world_debug_spawn_adventurer_pressed)
	_create_world_debug_button(button_row_2, "Refresh", "Refresh debug text.", _refresh_world_debug_panel)

	var button_row_3 := HBoxContainer.new()
	button_row_3.name = "WorldDebugButtonRow3"
	button_row_3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	debug_holder.add_child(button_row_3)

	_create_world_debug_button(button_row_3, "ClearAuto", "Press twice to delete autosave files.", _on_world_debug_clear_autosave_pressed)
	_create_world_debug_button(button_row_3, "ResetPause", "Force-clear pause/menu state if testing gets stuck.", _on_world_debug_reset_pause_pressed)

	debug_sidebar_scroll = ScrollContainer.new()
	debug_sidebar_scroll.name = "WorldDebugScroll"
	debug_sidebar_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	debug_sidebar_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	debug_sidebar_scroll.custom_minimum_size = Vector2(SIDEBAR_WIDTH - SIDEBAR_MARGIN * 2.0 - 36.0, 560.0)
	debug_holder.add_child(debug_sidebar_scroll)

	var debug_content := VBoxContainer.new()
	debug_content.name = "WorldDebugContent"
	debug_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	debug_sidebar_scroll.add_child(debug_content)

	debug_sidebar_label = Label.new()
	debug_sidebar_label.name = "WorldDebugLabel"
	debug_sidebar_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	debug_sidebar_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	debug_sidebar_label.custom_minimum_size = Vector2(SIDEBAR_WIDTH - SIDEBAR_MARGIN * 2.0 - 52.0, 0.0)
	debug_content.add_child(debug_sidebar_label)

func _create_world_debug_button(parent: Control, text: String, tooltip: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.tooltip_text = tooltip
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	parent.add_child(button)


func _on_world_debug_clear_autosave_pressed() -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null or not save_manager.has_method("request_clear_autosave_confirmation"):
		_refresh_world_sidebar_labels()
		return

	save_manager.request_clear_autosave_confirmation()
	_refresh_world_sidebar_labels()

func _on_world_debug_reset_pause_pressed() -> void:
	force_close_transient_ui()
	if GameState.has_method("set_simulation_paused"):
		GameState.set_simulation_paused(false)
	if get_tree() != null:
		get_tree().paused = false
	_refresh_world_sidebar_labels()

func _on_return_to_town_pressed() -> void:
	force_close_transient_ui()
	SceneRouter.go_to_town()

func _on_world_debug_add_money_pressed() -> void:
	GameState.add_money(25)
	_refresh_world_sidebar_labels()

func _on_world_debug_add_slime_gel_pressed() -> void:
	GameState.add_item("slime_gel", 1)
	_refresh_world_sidebar_labels()

func _on_world_debug_grow_slime_nest_pressed() -> void:
	GameState.grow_slime_nest(1)
	_refresh_world_sidebar_labels()

func _on_world_debug_spawn_adventurer_pressed() -> void:
	SceneRouter.request_spawn_adventurer()
	_refresh_world_sidebar_labels()

func _on_world_save_slot_button_pressed(slot_number: int) -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null and save_manager.has_method("set_active_slot"):
		save_manager.set_active_slot(slot_number)
	_refresh_world_save_panel()

func _get_persistent_town_view() -> Node:
	if SceneRouter.main_scene == null:
		return null

	if not SceneRouter.main_scene.has_method("get_view_by_name"):
		return null

	return SceneRouter.main_scene.get_view_by_name(SceneRouter.TOWN_VIEW_NAME)

func _on_world_save_all_pressed() -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null or not save_manager.has_method("save_all"):
		if save_status_label != null:
			save_status_label.text = "SaveManager unavailable."
		return

	var success: bool = bool(save_manager.save_all(_get_persistent_town_view(), true))
	if save_status_label != null:
		save_status_label.text = "World Save All: %s" % ("OK" if success else "Blocked / Partial")
	_refresh_world_save_panel()

func _on_world_load_all_pressed() -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null or not save_manager.has_method("load_all"):
		if save_status_label != null:
			save_status_label.text = "SaveManager unavailable."
		return

	var success: bool = bool(save_manager.load_all(_get_persistent_town_view(), true))
	if save_status_label != null:
		save_status_label.text = "World Load All: %s" % ("OK" if success else "Partial / No Save")
	_refresh_world_state()
	_refresh_world_save_panel()

func _refresh_world_sidebar_labels() -> void:
	if active_sidebar_mode == "world_info":
		_refresh_world_info_panel()
	elif active_sidebar_mode == "save_manager":
		_refresh_world_save_panel()
	elif active_sidebar_mode == "debug":
		_refresh_world_debug_panel()

func _refresh_world_info_panel() -> void:
	if world_info_label == null:
		return

	world_info_label.text = "WORLD MAP STATUS\n\nTime: Day %d - %s (%ds left)\nTravelers: %d\nReturned Records: %d\nVisible Slimes: %d\nVisitor Pool: %s\n\nNest: %s\nGrowth: %d\nLevel: %d\nRaid Pressure: %s\n\n%s\n\nUse Return to Town to go back to village management." % [
		GameClock.day_number,
		GameClock.get_phase_name(),
		int(ceil(GameClock.get_time_remaining())),
		GameState.get_world_traveler_count(),
		GameState.get_returned_traveler_count(),
		GameState.get_world_slime_count(),
		GameState.get_visitor_population_status_text() if GameState.has_method("get_visitor_population_status_text") else "Unavailable",
		GameState.slime_nest_status,
		GameState.slime_nest_growth,
		GameState.get_slime_nest_level(),
		GameState.get_raid_pressure_state(),
		GameState.get_slime_spawn_summary()
	]

func _refresh_world_save_panel() -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager == null:
		if save_status_label != null:
			save_status_label.text = "SaveManager unavailable."
		return

	_refresh_world_save_slot_buttons(save_manager)

	if save_slot_label != null and save_manager.has_method("get_active_slot_label_text"):
		save_slot_label.text = "SAVE SLOT\n%s" % str(save_manager.get_active_slot_label_text())

	if save_slot_timestamp_label != null and save_manager.has_method("get_active_slot_timestamp_text"):
		save_slot_timestamp_label.text = str(save_manager.get_active_slot_timestamp_text())

	if save_slot_summary_label != null and save_manager.has_method("get_active_slot_summary_text"):
		save_slot_summary_label.text = str(save_manager.get_active_slot_summary_text())

	if save_autosave_status_label != null and save_manager.has_method("get_autosave_status_text"):
		save_autosave_status_label.text = str(save_manager.get_autosave_status_text())

	if save_status_label != null:
		var last_save := "No save result."
		var last_load := "No load result."
		if save_manager.has_method("get_last_save_status_text"):
			last_save = str(save_manager.get_last_save_status_text())
		if save_manager.has_method("get_last_load_status_text"):
			last_load = str(save_manager.get_last_load_status_text())
		save_status_label.text = "WORLD MAP SAVE PANEL\nUses persistent Town data for full snapshots.\n\nLast Save:\n%s\n\nLast Load:\n%s" % [last_save, last_load]

func _refresh_world_save_slot_buttons(save_manager: Node) -> void:
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

func _get_world_autosave_clear_debug_text() -> String:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null and save_manager.has_method("get_autosave_clear_status_text"):
		return str(save_manager.get_autosave_clear_status_text()).replace("\n", " | ")

	return "Unavailable"

func _refresh_world_debug_panel() -> void:
	if debug_sidebar_label == null:
		return

	debug_sidebar_label.text = "WORLD MAP DEBUG\n\n-- View --\nView: %s\nTime: Day %d - %s (%ds left)\nFunds: %dg\nPotions: %d | Slime Gel: %d\n\n-- World --\nTravelers: %d\nReturned: %d\nVisible Slimes: %d\nTraveler Status: %s\nReturned Records: %s\nVisitor Pool: %s\n\n-- Threat --\nNest: %s | Growth %d | Level %d | %s\nSlime Spawns: %s\nNight Quests: %s\nNight Danger: %s\n\n-- Save / Recovery --\nAutosave Clear: %s\n\n-- Navigation --\nUse Town button to return to village." % [
		GameState.current_view_name,
		GameClock.day_number,
		GameClock.get_phase_name(),
		int(ceil(GameClock.get_time_remaining())),
		GameState.money,
		GameState.get_item_count("small_potion"),
		GameState.get_item_count("slime_gel"),
		GameState.get_world_traveler_count(),
		GameState.get_returned_traveler_count(),
		GameState.get_world_slime_count(),
		GameState.get_world_traveler_summary(),
		GameState.get_returned_traveler_summary(),
		GameState.get_visitor_population_status_text() if GameState.has_method("get_visitor_population_status_text") else "Unavailable",
		GameState.slime_nest_status,
		GameState.slime_nest_growth,
		GameState.get_slime_nest_level(),
		GameState.get_raid_pressure_state(),
		GameState.get_slime_spawn_summary(),
		GameState.get_night_quest_policy_text(),
		GameState.get_night_danger_summary(),
		_get_world_autosave_clear_debug_text()
	]

func _make_menu_panel_style() -> StyleBoxFlat:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color(0.045, 0.05, 0.045, 0.99)
	style_box.border_color = Color(0.26, 0.34, 0.26, 1.0)
	style_box.set_border_width_all(2)
	style_box.set_corner_radius_all(6)
	style_box.content_margin_left = 14.0
	style_box.content_margin_right = 14.0
	style_box.content_margin_top = 12.0
	style_box.content_margin_bottom = 12.0
	return style_box

func _create_esc_main_menu_overlay() -> void:
	esc_main_menu_overlay = Control.new()
	esc_main_menu_overlay.name = "WorldEscInGameMenuOverlay"
	esc_main_menu_overlay.visible = false
	esc_main_menu_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	esc_main_menu_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	esc_main_menu_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	esc_main_menu_overlay.z_index = 500
	add_child(esc_main_menu_overlay)

	var dim_background := ColorRect.new()
	dim_background.name = "WorldSolidDimBackground"
	dim_background.color = Color(0, 0, 0, 0.80)
	dim_background.mouse_filter = Control.MOUSE_FILTER_STOP
	dim_background.process_mode = Node.PROCESS_MODE_ALWAYS
	dim_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	esc_main_menu_overlay.add_child(dim_background)

	esc_main_menu_panel = PanelContainer.new()
	esc_main_menu_panel.name = "WorldEscMainButtonPanel"
	esc_main_menu_panel.offset_left = 460.0
	esc_main_menu_panel.offset_top = 155.0
	esc_main_menu_panel.offset_right = 800.0
	esc_main_menu_panel.offset_bottom = 500.0
	esc_main_menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	esc_main_menu_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	esc_main_menu_panel.add_theme_stylebox_override("panel", _make_menu_panel_style())
	esc_main_menu_overlay.add_child(esc_main_menu_panel)

	var main_vbox := VBoxContainer.new()
	main_vbox.name = "WorldEscMainVBox"
	main_vbox.add_theme_constant_override("separation", 10)
	main_vbox.process_mode = Node.PROCESS_MODE_ALWAYS
	esc_main_menu_panel.add_child(main_vbox)

	esc_main_menu_title_label = Label.new()
	esc_main_menu_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	esc_main_menu_title_label.text = "Paused"
	esc_main_menu_title_label.process_mode = Node.PROCESS_MODE_ALWAYS
	main_vbox.add_child(esc_main_menu_title_label)

	_create_esc_menu_button(main_vbox, "Resume", "Return to world map.", _on_esc_resume_pressed)
	_create_esc_menu_button(main_vbox, "Save / Load", "Open in-game save/load information.", func() -> void: _open_esc_submenu("save_load"))
	_create_esc_menu_button(main_vbox, "Settings", "Open settings categories.", func() -> void: _open_esc_submenu("settings"))
	_create_esc_menu_button(main_vbox, "Quit", "Quit placeholder. Title menu and exit flow come later.", func() -> void: _open_esc_submenu("quit"))

	esc_submenu_panel = PanelContainer.new()
	esc_submenu_panel.name = "WorldEscSubmenuPanel"
	esc_submenu_panel.visible = false
	esc_submenu_panel.offset_left = 545.0
	esc_submenu_panel.offset_top = 105.0
	esc_submenu_panel.offset_right = 1055.0
	esc_submenu_panel.offset_bottom = 630.0
	esc_submenu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	esc_submenu_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	esc_submenu_panel.add_theme_stylebox_override("panel", _make_menu_panel_style())
	esc_main_menu_overlay.add_child(esc_submenu_panel)

	var submenu_vbox := VBoxContainer.new()
	submenu_vbox.name = "WorldEscSubmenuVBox"
	submenu_vbox.add_theme_constant_override("separation", 8)
	submenu_vbox.process_mode = Node.PROCESS_MODE_ALWAYS
	esc_submenu_panel.add_child(submenu_vbox)

	var submenu_header := HBoxContainer.new()
	submenu_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	submenu_header.process_mode = Node.PROCESS_MODE_ALWAYS
	submenu_vbox.add_child(submenu_header)

	esc_submenu_title_label = Label.new()
	esc_submenu_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	esc_submenu_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	esc_submenu_title_label.text = "Menu"
	esc_submenu_title_label.process_mode = Node.PROCESS_MODE_ALWAYS
	submenu_header.add_child(esc_submenu_title_label)

	var close_button := Button.new()
	close_button.text = "X"
	close_button.tooltip_text = "Close submenu."
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.custom_minimum_size = Vector2(42, 32)
	close_button.process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.pressed.connect(_close_esc_submenu)
	submenu_header.add_child(close_button)

	var settings_row := HBoxContainer.new()
	settings_row.name = "EscSettingsCategoryRow"
	settings_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_row.visible = false
	settings_row.process_mode = Node.PROCESS_MODE_ALWAYS
	submenu_vbox.add_child(settings_row)

	_create_esc_menu_button(settings_row, "Graphics", "Show graphics settings placeholder.", func() -> void: _set_esc_submenu_content("graphics"))
	_create_esc_menu_button(settings_row, "Audio", "Show audio settings placeholder.", func() -> void: _set_esc_submenu_content("audio"))
	_create_esc_menu_button(settings_row, "Controls", "Show controls settings placeholder.", func() -> void: _set_esc_submenu_content("controls"))

	var submenu_scroll := ScrollContainer.new()
	submenu_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	submenu_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	submenu_scroll.custom_minimum_size = Vector2(470, 390)
	submenu_scroll.process_mode = Node.PROCESS_MODE_ALWAYS
	submenu_vbox.add_child(submenu_scroll)

	var scroll_content := VBoxContainer.new()
	scroll_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_content.process_mode = Node.PROCESS_MODE_ALWAYS
	submenu_scroll.add_child(scroll_content)

	esc_submenu_body_label = Label.new()
	esc_submenu_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	esc_submenu_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	esc_submenu_body_label.custom_minimum_size = Vector2(452, 0)
	esc_submenu_body_label.process_mode = Node.PROCESS_MODE_ALWAYS
	scroll_content.add_child(esc_submenu_body_label)

func _create_esc_menu_button(parent: Control, text: String, tooltip: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.tooltip_text = tooltip
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 42)
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.pressed.connect(callback)
	parent.add_child(button)

func _toggle_esc_main_menu() -> void:
	if esc_main_menu_overlay == null:
		return

	if esc_main_menu_overlay.visible:
		_close_esc_main_menu()
	else:
		_open_esc_main_menu()

func _open_esc_main_menu() -> void:
	if esc_main_menu_overlay == null:
		return

	esc_main_menu_active_tab = ""
	esc_main_menu_overlay.visible = true
	if esc_submenu_panel != null:
		esc_submenu_panel.visible = false

	if GameState.has_method("set_simulation_paused"):
		GameState.set_simulation_paused(true)
	get_tree().paused = true

func _close_esc_main_menu() -> void:
	if esc_main_menu_overlay != null:
		esc_main_menu_overlay.visible = false
	if esc_submenu_panel != null:
		esc_submenu_panel.visible = false

	if GameState.has_method("set_simulation_paused"):
		GameState.set_simulation_paused(false)
	get_tree().paused = false

func _on_esc_resume_pressed() -> void:
	_close_esc_main_menu()

func force_close_transient_ui() -> void:
	if esc_main_menu_overlay != null:
		esc_main_menu_overlay.visible = false
	if esc_submenu_panel != null:
		esc_submenu_panel.visible = false
	if GameState.has_method("set_simulation_paused"):
		GameState.set_simulation_paused(false)
	if get_tree() != null:
		get_tree().paused = false

func _open_esc_submenu(tab_id: String) -> void:
	if esc_submenu_panel == null:
		return

	esc_submenu_panel.visible = true
	_set_esc_submenu_content(tab_id)

func _close_esc_submenu() -> void:
	if esc_submenu_panel != null:
		esc_submenu_panel.visible = false
	esc_main_menu_active_tab = ""

func _set_esc_submenu_content(tab_id: String) -> void:
	esc_main_menu_active_tab = tab_id

	if esc_submenu_panel == null or esc_submenu_title_label == null or esc_submenu_body_label == null:
		return

	var settings_row := esc_submenu_panel.get_node_or_null("WorldEscSubmenuVBox/EscSettingsCategoryRow") as HBoxContainer
	if settings_row != null:
		settings_row.visible = tab_id in ["settings", "graphics", "audio", "controls"]

	var save_summary := "SaveManager unavailable."
	var autosave_summary := "Autosave unavailable."
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null:
		if save_manager.has_method("get_active_slot_label_text"):
			save_summary = str(save_manager.get_active_slot_label_text())
		if save_manager.has_method("get_autosave_status_text"):
			autosave_summary = str(save_manager.get_autosave_status_text())

	match tab_id:
		"save_load":
			esc_submenu_title_label.text = "Save / Load"
			esc_submenu_body_label.text = "WORLD MAP SAVE / LOAD\n\nCurrent Manual Slot:\n%s\n\n%s\n\nActual Save All / Load All is available in the World Map sidebar Save tab." % [
				save_summary,
				autosave_summary
			]
		"settings":
			esc_submenu_title_label.text = "Settings"
			esc_submenu_body_label.text = "SETTINGS\n\nSettings is the parent menu for Graphics, Audio, and Controls.\n\nChoose one of the settings categories above."
		"graphics":
			esc_submenu_title_label.text = "Settings / Graphics"
			esc_submenu_body_label.text = "GRAPHICS PLACEHOLDER\n\nFuture options:\n- Window mode\n- Resolution\n- Pixel scaling\n- UI scale\n- VSync"
		"audio":
			esc_submenu_title_label.text = "Settings / Audio"
			esc_submenu_body_label.text = "AUDIO PLACEHOLDER\n\nFuture options:\n- Master volume\n- Music volume\n- SFX volume\n- UI sounds"
		"controls":
			esc_submenu_title_label.text = "Settings / Controls"
			esc_submenu_body_label.text = "CONTROLS PLACEHOLDER\n\nFuture options:\n- Rebind controls\n- Camera movement\n- Pause/menu controls\n- Tooltip delay"
		"quit":
			esc_submenu_title_label.text = "Quit"
			esc_submenu_body_label.text = "QUIT PLACEHOLDER\n\nFuture behavior:\n- Warn about unsaved manual changes.\n- Offer Save and Quit.\n- Return to title menu.\n- Exit game from exported builds."
		_:
			esc_submenu_title_label.text = "Menu"
			esc_submenu_body_label.text = "Select an option."

func _refresh_world_state() -> void:
	_refresh_world_travelers()
	_refresh_slimes()
	_refresh_world_sidebar_labels()

func _refresh_world_travelers() -> void:
	var active_ids: Array[int] = []

	for index in range(GameState.get_world_travelers().size()):
		var traveler: Dictionary = GameState.get_world_travelers()[index]
		var traveler_id: int = int(traveler.get("id", index))
		active_ids.append(traveler_id)

		if not traveler_markers.has(traveler_id):
			var marker: Node2D = _create_traveler_marker(traveler)
			world_travelers_container.add_child(marker)
			traveler_markers[traveler_id] = marker

	var ids_to_remove: Array[int] = []
	for traveler_id in traveler_markers.keys():
		if not active_ids.has(int(traveler_id)):
			ids_to_remove.append(int(traveler_id))

	for traveler_id in ids_to_remove:
		var marker_to_remove: Node2D = traveler_markers[traveler_id]
		if is_instance_valid(marker_to_remove):
			marker_to_remove.queue_free()
		traveler_markers.erase(traveler_id)
		last_traveler_event_logs.erase(traveler_id)

	_update_marker_positions_and_labels()

func _refresh_slimes() -> void:
	var active_ids: Array[int] = []

	for index in range(GameState.get_world_slimes().size()):
		var slime: Dictionary = GameState.get_world_slimes()[index]
		var slime_id: int = int(slime.get("id", index))
		active_ids.append(slime_id)

		if not slime_markers.has(slime_id):
			var marker: Node2D = _create_slime_marker(slime)
			slimes_container.add_child(marker)
			slime_markers[slime_id] = marker
			_spawn_floating_text(marker, "Slime Spawn")

	var ids_to_remove: Array[int] = []
	for slime_id in slime_markers.keys():
		if not active_ids.has(int(slime_id)):
			ids_to_remove.append(int(slime_id))

	for slime_id in ids_to_remove:
		var marker_to_remove: Node2D = slime_markers[slime_id]
		if is_instance_valid(marker_to_remove):
			marker_to_remove.queue_free()
		slime_markers.erase(slime_id)
		last_slime_event_logs.erase(slime_id)

	_update_slime_positions_and_labels()

func _update_marker_positions_and_labels() -> void:
	var travelers: Array[Dictionary] = GameState.get_world_travelers()

	for index in range(travelers.size()):
		var traveler: Dictionary = travelers[index]
		var traveler_id: int = int(traveler.get("id", index))

		if not traveler_markers.has(traveler_id):
			continue

		var marker: Node2D = traveler_markers[traveler_id]
		var base_position: Vector2 = traveler.get("world_position", Vector2(642, 430))
		var offset: Vector2 = Vector2((index % 5) * 22, floori(float(index) / 5.0) * 28)
		marker.position = base_position + offset

		var label := marker.get_node_or_null("Label") as Label
		if label != null:
			label.text = _build_traveler_label(traveler)

		_show_world_event_if_needed(traveler, marker)

func _update_slime_positions_and_labels() -> void:
	var slimes: Array[Dictionary] = GameState.get_world_slimes()

	for index in range(slimes.size()):
		var slime: Dictionary = slimes[index]
		var slime_id: int = int(slime.get("id", index))

		if not slime_markers.has(slime_id):
			continue

		var marker: Node2D = slime_markers[slime_id]
		marker.position = slime.get("world_position", Vector2(915, 275))

		var label := marker.get_node_or_null("Label") as Label
		if label != null:
			label.text = _build_slime_label(slime)

		_show_slime_event_if_needed(slime, marker)

func _create_traveler_marker(traveler: Dictionary) -> Node2D:
	var marker := Node2D.new()
	marker.name = "WorldTraveler_%s" % str(traveler.get("id", 0))

	var body := ColorRect.new()
	body.name = "Body"
	body.size = Vector2(16, 16)
	body.position = Vector2(-8, -8)
	body.color = Color(0.75, 0.75, 0.95, 1)
	marker.add_child(body)

	var label := Label.new()
	label.name = "Label"
	label.position = Vector2(-70, -110)
	label.size = Vector2(280, 125)
	label.text = _build_traveler_label(traveler)
	marker.add_child(label)

	return marker

func _create_slime_marker(slime: Dictionary) -> Node2D:
	var marker := Node2D.new()
	marker.name = "Slime_%s" % str(slime.get("id", 0))

	var body := ColorRect.new()
	body.name = "Body"
	body.size = Vector2(14, 14)
	body.position = Vector2(-7, -7)
	body.color = Color(0.35, 0.9, 0.45, 1)
	marker.add_child(body)

	var label := Label.new()
	label.name = "Label"
	label.position = Vector2(-45, 12)
	label.size = Vector2(150, 54)
	label.text = _build_slime_label(slime)
	marker.add_child(label)

	return marker

func _show_world_event_if_needed(traveler: Dictionary, marker: Node2D) -> void:
	var traveler_id: int = int(traveler.get("id", -1))
	if traveler_id < 0:
		return

	var status: String = str(traveler.get("status", ""))
	var log_line: String = str(traveler.get("last_combat_log", ""))
	var floating_event_text: String = str(traveler.get("floating_event_text", ""))
	var damage_taken: int = int(traveler.get("last_damage_taken", 0))
	var damage_dealt: int = int(traveler.get("last_damage_dealt", 0))
	var event_key: String = "%s|%s|%s|%d|%d" % [status, log_line, floating_event_text, damage_taken, damage_dealt]

	if str(last_traveler_event_logs.get(traveler_id, "")) == event_key:
		return

	last_traveler_event_logs[traveler_id] = event_key

	var event_text: String = floating_event_text
	if event_text == "":
		event_text = _get_world_event_text(status, log_line)

	if event_text != "":
		_spawn_floating_text(marker, event_text)

	if damage_taken > 0:
		_spawn_floating_text(marker, "-%d HP" % damage_taken, Vector2(0, -66))

	if damage_dealt > 0 and status == "FightingVisibleSlime":
		_spawn_floating_text(marker, "%d dmg" % damage_dealt, Vector2(0, -90))

func _show_slime_event_if_needed(slime: Dictionary, marker: Node2D) -> void:
	var slime_id: int = int(slime.get("id", -1))
	if slime_id < 0:
		return

	var status: String = str(slime.get("status", ""))
	var log_line: String = str(slime.get("last_event_log", ""))
	var event_key: String = "%s|%s" % [status, log_line]

	if str(last_slime_event_logs.get(slime_id, "")) == event_key:
		return

	last_slime_event_logs[slime_id] = event_key

	if status == "AggroTraveler":
		_spawn_floating_text(marker, "Aggro!")
	elif status == "Engaged":
		_spawn_floating_text(marker, "Engaged")
	elif status == "Defeated":
		_spawn_floating_text(marker, "Slime Defeated")

func _get_world_event_text(status: String, log_line: String) -> String:
	if status == "FightingVisibleSlime":
		return "Combat!"

	if status == "NightQuesting":
		return "Night Quest"

	if status == "SearchingForSlime":
		return "Searching..."

	if status == "SeekingNextSlime":
		return "Hunting..."

	if status == "FleeingToTown":
		return "Fleeing!"

	if status == "ReturningWithLoot":
		return "Returning"

	if status == "InjuredReturning":
		return "Retreat!"

	if status == "ReturningLowEnergyAtNight":
		return "Too Tired - Return"

	if status == "ReturningNightRestricted":
		return "Night Quests Off"

	if log_line.contains("Won vs Slime"):
		return "Victory!"

	if log_line.contains("Lost vs Slime"):
		return "Defeated!"

	if log_line.contains("Slime ambush"):
		return "Ambush!"

	if log_line.contains("Day returned"):
		return "Day Returned"

	if log_line.contains("Night danger"):
		return "Night Danger"

	return ""

func _spawn_floating_text(anchor: Node2D, text: String, offset: Vector2 = Vector2(0, -42)) -> void:
	var floating_text := FLOATING_TEXT_SCENE.instantiate()
	add_child(floating_text)
	floating_text.global_position = anchor.global_position + offset

	if floating_text.has_method("setup"):
		floating_text.setup(text)

func _build_traveler_label(traveler: Dictionary) -> String:
	var inventory: Dictionary = traveler.get("inventory", {})
	var sale_message: String = str(traveler.get("sale_message", ""))
	var log_line: String = sale_message
	if log_line == "":
		log_line = str(traveler.get("last_combat_log", ""))

	return "%s\n%s | Gold:%d\nHP %d/%d | E:%d/%d\nP:%d G:%d | T:%d/%d K:%d\n%s" % [
		str(traveler.get("display_name", "Traveler")),
		str(traveler.get("status", "Unknown")),
		int(traveler.get("gold", 0)),
		int(traveler.get("hp", 0)),
		int(traveler.get("max_hp", 0)),
		int(traveler.get("energy", 0)),
		int(traveler.get("max_energy", 0)),
		int(inventory.get("small_potion", 0)),
		int(inventory.get("slime_gel", 0)),
		int(traveler.get("trip_count", 0)),
		int(traveler.get("max_trip_count", 0)),
		int(traveler.get("slime_kills_this_outing", 0)),
		log_line
	]

func _build_slime_label(slime: Dictionary) -> String:
	return "%s Lv.%d\n%s\nHP:%d ATK:%d" % [
		str(slime.get("display_name", "Slime")),
		int(slime.get("level", 1)),
		str(slime.get("status", "Wandering")),
		int(slime.get("max_hp", GameState.get_current_slime_max_hp())),
		int(slime.get("attack", GameState.get_current_slime_attack()))
	]
