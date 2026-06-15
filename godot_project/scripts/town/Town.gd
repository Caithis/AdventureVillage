extends Node2D

const ADVENTURER_SCENE: PackedScene = preload("res://scenes/adventurers/Adventurer.tscn")

@onready var adventurers_container: Node2D = $Adventurers
@onready var town_entrance: Marker2D = $Markers/TownEntrance
@onready var general_store_point: Marker2D = $Markers/GeneralStorePoint
@onready var inn_point: Marker2D = $Markers/InnPoint
@onready var exit_to_world_point: Marker2D = $Markers/ExitToWorldPoint
@onready var building_menu: Control = $BuildingMenu
@onready var general_store_building: Node = $Buildings/GeneralStore

var spawn_count: int = 0
var return_spawn_count: int = 0
var is_checking_returned_travelers: bool = false

func _ready() -> void:
	print("Town scene loaded.")
	GameState.state_changed.connect(_on_game_state_changed)
	if general_store_building.has_signal("building_clicked"):
		general_store_building.building_clicked.connect(_on_building_clicked)
	_check_for_returned_travelers()

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


func _on_building_clicked(building_id: String) -> void:
	if building_menu != null and building_menu.has_method("open_for_building"):
		building_menu.open_for_building(building_id)
