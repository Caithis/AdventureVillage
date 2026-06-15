extends Node

signal state_changed

const SMALL_POTION_ID := "small_potion"
const SLIME_GEL_ID := "slime_gel"

var money: int = 500
var current_view_name: String = "Unknown"

var town_inventory: Dictionary = {
	SMALL_POTION_ID: 5,
	SLIME_GEL_ID: 0,
}

var adventurers: Array[Node] = []
var world_travelers: Array[Dictionary] = []
var next_world_traveler_id: int = 1

var slime_nest_status: String = "Dormant"
var slime_nest_growth: int = 0

func emit_state_changed() -> void:
	state_changed.emit()

func add_money(amount: int) -> void:
	money += amount
	state_changed.emit()

func spend_money(amount: int) -> bool:
	if amount < 0:
		push_warning("Cannot spend a negative amount.")
		return false

	if money < amount:
		return false

	money -= amount
	state_changed.emit()
	return true

func add_item(item_id: String, amount: int) -> void:
	if amount <= 0:
		return

	town_inventory[item_id] = get_item_count(item_id) + amount
	state_changed.emit()

func remove_item(item_id: String, amount: int) -> bool:
	if amount <= 0:
		return false

	var current_amount := get_item_count(item_id)
	if current_amount < amount:
		return false

	town_inventory[item_id] = current_amount - amount
	state_changed.emit()
	return true

func get_item_count(item_id: String) -> int:
	return int(town_inventory.get(item_id, 0))

func has_item(item_id: String, amount: int = 1) -> bool:
	return get_item_count(item_id) >= amount

func register_adventurer(adventurer: Node) -> void:
	if adventurer == null:
		return

	if not adventurers.has(adventurer):
		adventurers.append(adventurer)
		state_changed.emit()

func unregister_adventurer(adventurer: Node) -> void:
	if adventurers.has(adventurer):
		adventurers.erase(adventurer)
		state_changed.emit()

func get_adventurer_count() -> int:
	_remove_invalid_adventurer_references()
	return adventurers.size()

func _remove_invalid_adventurer_references() -> void:
	var valid_adventurers: Array[Node] = []
	for adventurer in adventurers:
		if is_instance_valid(adventurer):
			valid_adventurers.append(adventurer)
	adventurers = valid_adventurers

func add_world_traveler_from_adventurer(adventurer: Node) -> Dictionary:
	if adventurer == null:
		return {}

	var traveler := {
		"id": next_world_traveler_id,
		"display_name": _safe_get_property(adventurer, "display_name", "Unknown"),
		"class_id": _safe_get_property(adventurer, "class_id", "fighter"),
		"level": _safe_get_property(adventurer, "level", 1),
		"gold": _safe_get_property(adventurer, "gold", 0),
		"inventory": _safe_get_property(adventurer, "inventory", {}).duplicate(true),
		"status": "Near Town",
		"world_position": Vector2(642, 430),
	}

	next_world_traveler_id += 1
	world_travelers.append(traveler)
	state_changed.emit()
	return traveler

func get_world_travelers() -> Array[Dictionary]:
	return world_travelers

func get_world_traveler_count() -> int:
	return world_travelers.size()

func _safe_get_property(object: Object, property_name: String, fallback: Variant) -> Variant:
	if object == null:
		return fallback

	# In Godot 4, direct dynamic get() returns null if missing.
	var value: Variant = object.get(property_name)
	if value == null:
		return fallback

	return value

func grow_slime_nest(amount: int = 1) -> void:
	slime_nest_growth += amount

	if slime_nest_growth <= 0:
		slime_nest_status = "Dormant"
	elif slime_nest_growth < 3:
		slime_nest_status = "Growing"
	elif slime_nest_growth < 6:
		slime_nest_status = "Dangerous"
	else:
		slime_nest_status = "Raid Risk"

	state_changed.emit()
