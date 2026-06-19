extends Control

const EXPANDED_PANEL_SIZE := Vector2(420, 630)
const COLLAPSED_PANEL_SIZE := Vector2(420, 36)

@onready var panel_container: PanelContainer = $PanelContainer
@onready var collapse_button: Button = $PanelContainer/VBoxRoot/CollapseButton
@onready var scroll_container: ScrollContainer = $PanelContainer/VBoxRoot/ScrollContainer

@onready var view_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/ViewLabel
@onready var time_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/TimeLabel
@onready var money_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/MoneyLabel
@onready var inventory_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/InventoryLabel
@onready var adventurer_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/AdventurerLabel
@onready var world_traveler_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/WorldTravelerLabel
@onready var returned_traveler_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/ReturnedTravelerLabel
@onready var world_traveler_summary_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/WorldTravelerSummaryLabel
@onready var returned_traveler_summary_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/ReturnedTravelerSummaryLabel
@onready var threat_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/ThreatLabel
@onready var slime_spawn_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/SlimeSpawnLabel
@onready var night_policy_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/NightPolicyLabel
@onready var night_danger_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/NightDangerLabel
@onready var general_store_policy_label: Label = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/GeneralStorePolicyLabel

@onready var town_button: Button = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/TownButton
@onready var world_map_button: Button = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/WorldMapButton
@onready var add_money_button: Button = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/AddMoneyButton
@onready var add_slime_gel_button: Button = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/AddSlimeGelButton
@onready var grow_slime_nest_button: Button = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/GrowSlimeNestButton
@onready var spawn_adventurer_button: Button = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/SpawnAdventurerButton
@onready var toggle_night_quests_button: Button = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/ToggleNightQuestsButton
@onready var toggle_slime_gel_buying_button: Button = $PanelContainer/VBoxRoot/ScrollContainer/VBoxContainer/ToggleSlimeGelBuyingButton

var cached_day_number: int = 1
var cached_phase_name: String = "Day"
var cached_time_remaining: float = 0.0
var debug_collapsed: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_container.mouse_filter = Control.MOUSE_FILTER_STOP
	collapse_button.pressed.connect(_on_collapse_button_pressed)
	town_button.pressed.connect(_on_town_button_pressed)
	world_map_button.pressed.connect(_on_world_map_button_pressed)
	add_money_button.pressed.connect(_on_add_money_button_pressed)
	add_slime_gel_button.pressed.connect(_on_add_slime_gel_button_pressed)
	grow_slime_nest_button.pressed.connect(_on_grow_slime_nest_button_pressed)
	spawn_adventurer_button.pressed.connect(_on_spawn_adventurer_button_pressed)
	toggle_night_quests_button.pressed.connect(_on_toggle_night_quests_button_pressed)
	toggle_slime_gel_buying_button.pressed.connect(_on_toggle_slime_gel_buying_button_pressed)

	GameState.state_changed.connect(_refresh_state_labels)
	GameClock.time_updated.connect(_on_time_updated)

	_set_debug_collapsed(false)
	_refresh_state_labels()

func _on_collapse_button_pressed() -> void:
	_set_debug_collapsed(not debug_collapsed)

func _set_debug_collapsed(should_collapse: bool) -> void:
	debug_collapsed = should_collapse
	scroll_container.visible = not debug_collapsed
	collapse_button.text = "Show Debug" if debug_collapsed else "Hide Debug"

	if debug_collapsed:
		panel_container.custom_minimum_size = COLLAPSED_PANEL_SIZE
		panel_container.size = COLLAPSED_PANEL_SIZE
		panel_container.offset_right = panel_container.offset_left + COLLAPSED_PANEL_SIZE.x
		panel_container.offset_bottom = panel_container.offset_top + COLLAPSED_PANEL_SIZE.y
	else:
		panel_container.custom_minimum_size = EXPANDED_PANEL_SIZE
		panel_container.size = EXPANDED_PANEL_SIZE
		panel_container.offset_right = panel_container.offset_left + EXPANDED_PANEL_SIZE.x
		panel_container.offset_bottom = panel_container.offset_top + EXPANDED_PANEL_SIZE.y
		scroll_container.custom_minimum_size = Vector2(0, EXPANDED_PANEL_SIZE.y - 70)

func _on_town_button_pressed() -> void:
	SceneRouter.go_to_town()

func _on_world_map_button_pressed() -> void:
	SceneRouter.go_to_world_map()

func _on_add_money_button_pressed() -> void:
	GameState.add_money(25)

func _on_add_slime_gel_button_pressed() -> void:
	GameState.add_item("slime_gel", 1)

func _on_grow_slime_nest_button_pressed() -> void:
	GameState.grow_slime_nest(1)

func _on_spawn_adventurer_button_pressed() -> void:
	SceneRouter.request_spawn_adventurer()

func _on_toggle_night_quests_button_pressed() -> void:
	GameState.toggle_night_quests()

func _on_toggle_slime_gel_buying_button_pressed() -> void:
	GameState.toggle_general_store_buys_slime_gel()

func _on_time_updated(day_number: int, phase_name: String, time_remaining: float, _phase_progress: float) -> void:
	cached_day_number = day_number
	cached_phase_name = phase_name
	cached_time_remaining = time_remaining
	_refresh_time_label()

func _refresh_time_label() -> void:
	time_label.text = "Time: Day %d - %s (%ds left)" % [
		cached_day_number,
		cached_phase_name,
		int(ceil(cached_time_remaining))
	]

func _refresh_state_labels() -> void:
	view_label.text = "View: " + GameState.current_view_name
	money_label.text = "Village Funds: %d" % GameState.money
	inventory_label.text = "Inventory: Potions %d | Slime Gel %d" % [
		GameState.get_item_count("small_potion"),
		GameState.get_item_count("slime_gel")
	]
	adventurer_label.text = "In-Town Adventurers: %d" % GameState.get_adventurer_count()
	world_traveler_label.text = "World Travelers: %d" % GameState.get_world_traveler_count()
	returned_traveler_label.text = "Returned Travelers: %d" % GameState.get_returned_traveler_count()
	world_traveler_summary_label.text = "Traveler Status: " + GameState.get_world_traveler_summary()
	returned_traveler_summary_label.text = "Returned: " + GameState.get_returned_traveler_summary()
	threat_label.text = "Slime Nest: %s | Growth %d | Level %d | %s" % [
		GameState.slime_nest_status,
		GameState.slime_nest_growth,
		GameState.get_slime_nest_level(),
		GameState.get_raid_pressure_state()
	]
	slime_spawn_label.text = "Slime Spawns: " + GameState.get_slime_spawn_summary()
	night_policy_label.text = "Night Quests: " + GameState.get_night_quest_policy_text()
	night_danger_label.text = "Night Danger: " + GameState.get_night_danger_summary()
	general_store_policy_label.text = "General Store: " + GameState.get_general_store_buy_policy_text()
	toggle_night_quests_button.text = "Toggle Night Quests (%s)" % GameState.get_night_quest_policy_text()
	toggle_slime_gel_buying_button.text = "Toggle Store Slime Gel Buying (%s)" % GameState.get_general_store_buy_policy_text()
	_refresh_time_label()
