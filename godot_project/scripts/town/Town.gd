extends Node2D

const ADVENTURER_SCENE: PackedScene = preload("res://scenes/adventurers/Adventurer.tscn")

@onready var adventurers_container: Node2D = $Adventurers
@onready var town_entrance: Marker2D = $Markers/TownEntrance
@onready var general_store_point: Marker2D = $Markers/GeneralStorePoint
@onready var exit_to_world_point: Marker2D = $Markers/ExitToWorldPoint

var spawn_count: int = 0

func _ready() -> void:
	print("Town scene loaded.")

func spawn_placeholder_adventurer() -> void:
	var adventurer := ADVENTURER_SCENE.instantiate()
	adventurers_container.add_child(adventurer)

	var spawn_offset := Vector2((spawn_count % 8) * 24, -int(spawn_count / 8) * 24)
	adventurer.global_position = town_entrance.global_position + spawn_offset

	if adventurer.has_method("setup_placeholder"):
		adventurer.setup_placeholder(_generate_adventurer_name(), "fighter", 1)

	if adventurer.has_method("start_town_routine"):
		adventurer.start_town_routine(
			town_entrance.global_position + spawn_offset,
			general_store_point.global_position + spawn_offset,
			exit_to_world_point.global_position + spawn_offset
		)

	GameState.register_adventurer(adventurer)

	spawn_count += 1
	print("Spawned adventurer: ", adventurer.name)

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
