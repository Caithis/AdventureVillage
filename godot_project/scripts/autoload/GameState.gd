extends Node

signal state_changed

const SMALL_POTION_ID := "small_potion"
const SLIME_GEL_ID := "slime_gel"

const SLIME_NEST_WORLD_POSITION := Vector2(915, 275)
const TOWN_WORLD_POSITION := Vector2(642, 430)

const WORLD_TRAVELER_SPEED := 45.0
const WORLD_RETURN_SPEED := 55.0
const WORLD_ARRIVAL_DISTANCE := 8.0

const SLIME_MAX_HP := 18
const SLIME_ATTACK := 4
const SLIME_SPEED := 0.85
const SLIME_GEL_REWARD := 2
const SLIME_GEL_SELL_VALUE := 5

const SMALL_POTION_HEAL_AMOUNT := 15
const POTION_USE_HP_RATIO := 0.40

var money: int = 500
var current_view_name: String = "Unknown"

var town_inventory: Dictionary = {
	SMALL_POTION_ID: 5,
	SLIME_GEL_ID: 0,
}

var adventurers: Array[Node] = []
var world_travelers: Array[Dictionary] = []
var returned_travelers: Array[Dictionary] = []
var next_world_traveler_id: int = 1

var slime_nest_status: String = "Dormant"
var slime_nest_growth: int = 0

var _world_simulation_emit_timer: float = 0.0
var _world_simulation_emit_interval: float = 0.15

func _process(delta: float) -> void:
	_update_world_travelers(delta)

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
		"status": "TravelingToSlimeNest",
		"world_position": TOWN_WORLD_POSITION,
		"target_position": SLIME_NEST_WORLD_POSITION,
		"max_hp": 30,
		"hp": 30,
		"attack": 7,
		"speed": 1.0,
		"combat_resolved": false,
		"has_returned_to_town": false,
		"has_sold_loot": false,
		"sale_message": "",
		"last_combat_log": "Traveling to Slime Nest.",
	}

	next_world_traveler_id += 1
	world_travelers.append(traveler)
	state_changed.emit()
	return traveler

func get_world_travelers() -> Array[Dictionary]:
	return world_travelers

func get_world_traveler_count() -> int:
	return world_travelers.size()

func get_returned_travelers() -> Array[Dictionary]:
	return returned_travelers

func get_returned_traveler_count() -> int:
	return returned_travelers.size()

func get_world_traveler_summary() -> String:
	if world_travelers.is_empty():
		return "None"

	var summary_parts: Array[String] = []

	for traveler in world_travelers:
		var traveler_name := str(traveler.get("display_name", "Traveler"))
		var status := str(traveler.get("status", "Unknown"))
		summary_parts.append("%s:%s" % [traveler_name, status])

		if summary_parts.size() >= 3:
			break

	if world_travelers.size() > 3:
		summary_parts.append("+%d more" % (world_travelers.size() - 3))

	return " | ".join(summary_parts)

func get_returned_traveler_summary() -> String:
	if returned_travelers.is_empty():
		return "None"

	var summary_parts: Array[String] = []

	for traveler in returned_travelers:
		var traveler_name := str(traveler.get("display_name", "Traveler"))
		var status := str(traveler.get("status", "Returned"))
		var sale_message := str(traveler.get("sale_message", ""))
		var inventory: Dictionary = traveler.get("inventory", {})
		var slime_gel := int(inventory.get(SLIME_GEL_ID, 0))

		if sale_message != "":
			summary_parts.append("%s:%s %s" % [traveler_name, status, sale_message])
		else:
			summary_parts.append("%s:%s Gel:%d" % [traveler_name, status, slime_gel])

		if summary_parts.size() >= 3:
			break

	if returned_travelers.size() > 3:
		summary_parts.append("+%d more" % (returned_travelers.size() - 3))

	return " | ".join(summary_parts)

func _update_world_travelers(delta: float) -> void:
	if world_travelers.is_empty():
		return

	var changed := false

	for index in world_travelers.size():
		var traveler := world_travelers[index]
		var status := str(traveler.get("status", ""))

		if status == "TravelingToSlimeNest":
			changed = _move_traveler_toward_target(traveler, SLIME_NEST_WORLD_POSITION, WORLD_TRAVELER_SPEED, delta)

			if _traveler_reached_position(traveler, SLIME_NEST_WORLD_POSITION):
				traveler["world_position"] = SLIME_NEST_WORLD_POSITION
				traveler["status"] = "FightingSlime"
				traveler["last_combat_log"] = "Encountered Slime."
				_resolve_slime_combat(traveler)
				changed = true

		elif status == "ReturningWithLoot" or status == "InjuredReturning":
			changed = _move_traveler_toward_target(traveler, TOWN_WORLD_POSITION, WORLD_RETURN_SPEED, delta)

			if _traveler_reached_position(traveler, TOWN_WORLD_POSITION):
				traveler["world_position"] = TOWN_WORLD_POSITION
				_mark_traveler_arrived_at_town(traveler)
				changed = true

		world_travelers[index] = traveler

	_world_simulation_emit_timer += delta
	if changed and _world_simulation_emit_timer >= _world_simulation_emit_interval:
		_world_simulation_emit_timer = 0.0
		state_changed.emit()

func _move_traveler_toward_target(traveler: Dictionary, target_position: Vector2, speed: float, delta: float) -> bool:
	var current_position: Vector2 = traveler.get("world_position", TOWN_WORLD_POSITION)
	var new_position := _move_position_toward(current_position, target_position, speed * delta)
	traveler["target_position"] = target_position
	traveler["world_position"] = new_position
	return current_position != new_position

func _traveler_reached_position(traveler: Dictionary, target_position: Vector2) -> bool:
	var current_position: Vector2 = traveler.get("world_position", TOWN_WORLD_POSITION)
	return current_position.distance_to(target_position) <= WORLD_ARRIVAL_DISTANCE

func _mark_traveler_arrived_at_town(traveler: Dictionary) -> void:
	if bool(traveler.get("has_returned_to_town", false)):
		return

	traveler["has_returned_to_town"] = true

	var previous_status := str(traveler.get("status", ""))
	if previous_status == "ReturningWithLoot":
		traveler["status"] = "ArrivedAtTownWithLoot"
		traveler["last_combat_log"] = "Returned to town with loot."
		_sell_slime_gel_to_town(traveler)
	elif previous_status == "InjuredReturning":
		traveler["status"] = "ArrivedAtTownInjured"
		traveler["last_combat_log"] = "Returned to town injured."
	else:
		traveler["status"] = "ArrivedAtTown"
		traveler["last_combat_log"] = "Returned to town."

	returned_travelers.append(traveler.duplicate(true))
	state_changed.emit()

func _sell_slime_gel_to_town(traveler: Dictionary) -> void:
	if bool(traveler.get("has_sold_loot", false)):
		return

	var inventory: Dictionary = traveler.get("inventory", {})
	var slime_gel_amount := int(inventory.get(SLIME_GEL_ID, 0))

	if slime_gel_amount <= 0:
		traveler["sale_message"] = "No loot to sell."
		return

	var sale_total := slime_gel_amount * SLIME_GEL_SELL_VALUE

	town_inventory[SLIME_GEL_ID] = get_item_count(SLIME_GEL_ID) + slime_gel_amount
	inventory[SLIME_GEL_ID] = 0

	traveler["inventory"] = inventory
	traveler["gold"] = int(traveler.get("gold", 0)) + sale_total
	traveler["has_sold_loot"] = true
	traveler["status"] = "SoldLoot"
	traveler["sale_message"] = "Sold %d Slime Gel for %dg." % [slime_gel_amount, sale_total]
	traveler["last_combat_log"] = traveler["sale_message"]

func _move_position_toward(current_position: Vector2, target_position: Vector2, max_distance: float) -> Vector2:
	var direction := target_position - current_position
	var distance := direction.length()

	if distance <= max_distance or distance <= 0.0:
		return target_position

	return current_position + direction.normalized() * max_distance

func _resolve_slime_combat(traveler: Dictionary) -> void:
	if bool(traveler.get("combat_resolved", false)):
		return

	traveler["combat_resolved"] = true

	var adventurer_hp := int(traveler.get("hp", 30))
	var adventurer_max_hp := int(traveler.get("max_hp", 30))
	var adventurer_attack := int(traveler.get("attack", 7))
	var adventurer_speed := float(traveler.get("speed", 1.0))
	var adventurer_meter := 0.0

	var slime_hp := SLIME_MAX_HP
	var slime_meter := 0.0

	var inventory: Dictionary = traveler.get("inventory", {})
	var potion_used := false
	var combat_log: Array[String] = []
	combat_log.append("Combat started vs Slime.")

	var rounds := 0
	while adventurer_hp > 0 and slime_hp > 0 and rounds < 100:
		rounds += 1
		adventurer_meter += adventurer_speed
		slime_meter += SLIME_SPEED

		if adventurer_hp <= int(adventurer_max_hp * POTION_USE_HP_RATIO) and int(inventory.get(SMALL_POTION_ID, 0)) > 0 and not potion_used:
			inventory[SMALL_POTION_ID] = int(inventory.get(SMALL_POTION_ID, 0)) - 1
			adventurer_hp = mini(adventurer_hp + SMALL_POTION_HEAL_AMOUNT, adventurer_max_hp)
			potion_used = true
			combat_log.append("Used Small Potion.")

		if adventurer_meter >= 1.0:
			adventurer_meter = 0.0
			slime_hp -= adventurer_attack
			combat_log.append("Hit Slime for %d." % adventurer_attack)

			if slime_hp <= 0:
				break

		if slime_meter >= 1.0:
			slime_meter = 0.0
			adventurer_hp -= SLIME_ATTACK
			combat_log.append("Slime hit for %d." % SLIME_ATTACK)

	traveler["hp"] = maxi(adventurer_hp, 0)
	traveler["inventory"] = inventory

	if slime_hp <= 0:
		inventory[SLIME_GEL_ID] = int(inventory.get(SLIME_GEL_ID, 0)) + SLIME_GEL_REWARD
		traveler["inventory"] = inventory
		traveler["status"] = "ReturningWithLoot"
		traveler["target_position"] = TOWN_WORLD_POSITION
		traveler["last_combat_log"] = "Won vs Slime. Returning with %d Slime Gel." % SLIME_GEL_REWARD
	elif adventurer_hp <= 0:
		traveler["status"] = "InjuredReturning"
		traveler["target_position"] = TOWN_WORLD_POSITION
		traveler["last_combat_log"] = "Lost vs Slime. Returning injured."
	else:
		traveler["status"] = "InjuredReturning"
		traveler["target_position"] = TOWN_WORLD_POSITION
		traveler["last_combat_log"] = "Combat timed out. Retreating."

	if potion_used:
		traveler["last_combat_log"] += " Potion used."

	state_changed.emit()

func _safe_get_property(object: Object, property_name: String, fallback: Variant) -> Variant:
	if object == null:
		return fallback

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
