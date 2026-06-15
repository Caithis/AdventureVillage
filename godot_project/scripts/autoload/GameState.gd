extends Node

signal state_changed

var money: int = 500
var current_view_name: String = "Unknown"

var town_inventory: Dictionary = {
	"small_potion": 5,
	"slime_gel": 0,
}

var adventurers: Array[Node] = []

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
