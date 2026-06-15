extends Control

@onready var view_label: Label = $PanelContainer/VBoxContainer/ViewLabel
@onready var time_label: Label = $PanelContainer/VBoxContainer/TimeLabel
@onready var money_label: Label = $PanelContainer/VBoxContainer/MoneyLabel
@onready var inventory_label: Label = $PanelContainer/VBoxContainer/InventoryLabel
@onready var adventurer_label: Label = $PanelContainer/VBoxContainer/AdventurerLabel
@onready var world_traveler_label: Label = $PanelContainer/VBoxContainer/WorldTravelerLabel
@onready var returned_traveler_label: Label = $PanelContainer/VBoxContainer/ReturnedTravelerLabel
@onready var world_traveler_summary_label: Label = $PanelContainer/VBoxContainer/WorldTravelerSummaryLabel
@onready var returned_traveler_summary_label: Label = $PanelContainer/VBoxContainer/ReturnedTravelerSummaryLabel
@onready var threat_label: Label = $PanelContainer/VBoxContainer/ThreatLabel

@onready var town_button: Button = $PanelContainer/VBoxContainer/TownButton
@onready var world_map_button: Button = $PanelContainer/VBoxContainer/WorldMapButton
@onready var add_money_button: Button = $PanelContainer/VBoxContainer/AddMoneyButton
@onready var add_slime_gel_button: Button = $PanelContainer/VBoxContainer/AddSlimeGelButton
@onready var grow_slime_nest_button: Button = $PanelContainer/VBoxContainer/GrowSlimeNestButton
@onready var spawn_adventurer_button: Button = $PanelContainer/VBoxContainer/SpawnAdventurerButton

var cached_day_number: int = 1
var cached_phase_name: String = "Day"
var cached_time_remaining: float = 0.0

func _ready() -> void:
	town_button.pressed.connect(_on_town_button_pressed)
	world_map_button.pressed.connect(_on_world_map_button_pressed)
	add_money_button.pressed.connect(_on_add_money_button_pressed)
	add_slime_gel_button.pressed.connect(_on_add_slime_gel_button_pressed)
	grow_slime_nest_button.pressed.connect(_on_grow_slime_nest_button_pressed)
	spawn_adventurer_button.pressed.connect(_on_spawn_adventurer_button_pressed)

	GameState.state_changed.connect(_refresh_state_labels)
	GameClock.time_updated.connect(_on_time_updated)

	_refresh_state_labels()

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
	threat_label.text = "Slime Nest: %s | Growth %d" % [
		GameState.slime_nest_status,
		GameState.slime_nest_growth
	]
	_refresh_time_label()
