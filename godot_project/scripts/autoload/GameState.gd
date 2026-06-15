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

const SLIME_NEST_BASE_MAX_ACTIVE_SLIMES := 3
const SLIME_NEST_HARD_MAX_ACTIVE_SLIMES := 6
const SLIME_NEST_BASE_SPAWN_INTERVAL := 5.0
const SLIME_NEST_MIN_SPAWN_INTERVAL := 2.0
const SLIME_WANDER_RADIUS := 90.0
const SLIME_WANDER_SPEED := 22.0
const SLIME_AGGRO_SPEED := 36.0
const SLIME_AGGRO_RADIUS := 95.0
const SLIME_CONTACT_DISTANCE := 15.0
const MAX_SLIMES_TARGETING_ONE_TRAVELER := 1

const NIGHT_SLIME_HP_MULTIPLIER := 1.5
const NIGHT_SLIME_ATTACK_MULTIPLIER := 1.5
const NIGHT_RETREAT_ENERGY_THRESHOLD := 40

const SMALL_POTION_HEAL_AMOUNT := 15
const POTION_USE_HP_RATIO := 0.40

const DEFAULT_MAX_ENERGY := 100
const WORLD_TRIP_ENERGY_COST := 45

var money: int = 500
var current_view_name: String = "Unknown"

var allow_night_quests: bool = true
var general_store_buys_slime_gel: bool = true

var town_inventory: Dictionary = {
	SMALL_POTION_ID: 5,
	SLIME_GEL_ID: 0,
}

var adventurers: Array[Node] = []
var world_travelers: Array[Dictionary] = []
var returned_travelers: Array[Dictionary] = []
var world_slimes: Array[Dictionary] = []

var next_world_traveler_id: int = 1
var next_world_slime_id: int = 1

var slime_nest_status: String = "Dormant"
var slime_nest_growth: int = 0

var _world_simulation_emit_timer: float = 0.0
var _world_simulation_emit_interval: float = 0.15
var _slime_spawn_timer: float = 999.0

func _process(delta: float) -> void:
	var changed := false
	changed = _update_world_slimes(delta) or changed
	changed = _update_world_travelers(delta) or changed

	_world_simulation_emit_timer += delta
	if changed and _world_simulation_emit_timer >= _world_simulation_emit_interval:
		_world_simulation_emit_timer = 0.0
		state_changed.emit()

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

func toggle_night_quests() -> void:
	allow_night_quests = not allow_night_quests
	state_changed.emit()

func get_night_quest_policy_text() -> String:
	if allow_night_quests:
		return "Enabled"
	return "Disabled"

func get_night_danger_summary() -> String:
	return "Night Slime HP x%.1f | ATK x%.1f | Retreat E<=%d" % [
		NIGHT_SLIME_HP_MULTIPLIER,
		NIGHT_SLIME_ATTACK_MULTIPLIER,
		NIGHT_RETREAT_ENERGY_THRESHOLD
	]

func toggle_general_store_buys_slime_gel() -> void:
	general_store_buys_slime_gel = not general_store_buys_slime_gel
	state_changed.emit()

func set_general_store_buys_slime_gel(enabled: bool) -> void:
	general_store_buys_slime_gel = enabled
	state_changed.emit()

func can_general_store_buy_item(item_id: String) -> bool:
	if item_id == SLIME_GEL_ID:
		return general_store_buys_slime_gel

	return true

func get_general_store_buy_policy_text() -> String:
	if general_store_buys_slime_gel:
		return "Buying Slime Gel"
	return "Not Buying Slime Gel"

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
		"trip_count": _safe_get_property(adventurer, "trip_count", 0),
		"max_trip_count": _safe_get_property(adventurer, "max_trip_count", 2),
		"last_night_sleep_day": _safe_get_property(adventurer, "last_night_sleep_day", -1),
		"energy": _safe_get_property(adventurer, "energy", DEFAULT_MAX_ENERGY),
		"max_energy": _safe_get_property(adventurer, "max_energy", DEFAULT_MAX_ENERGY),
		"status": "TravelingToSlimeNest",
		"world_position": TOWN_WORLD_POSITION,
		"target_position": SLIME_NEST_WORLD_POSITION,
		"target_slime_id": -1,
		"max_hp": _safe_get_property(adventurer, "max_health", 30),
		"hp": _safe_get_property(adventurer, "health", 30),
		"attack": 7,
		"speed": 1.0,
		"combat_resolved": false,
		"has_returned_to_town": false,
		"town_reentry_claimed": false,
		"sale_message": "",
		"last_combat_log": "Traveling to Slime Nest.",
	}

	traveler["energy"] = maxi(int(traveler.get("energy", DEFAULT_MAX_ENERGY)) - WORLD_TRIP_ENERGY_COST, 0)
	traveler["last_combat_log"] = "Traveling to Slime Nest. Energy -%d." % WORLD_TRIP_ENERGY_COST

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

func get_world_slimes() -> Array[Dictionary]:
	var active_slimes: Array[Dictionary] = []
	for slime in world_slimes:
		if bool(slime.get("is_active", true)):
			active_slimes.append(slime)
	return active_slimes

func get_world_slime_count() -> int:
	return get_world_slimes().size()

func get_slime_nest_max_active_slimes() -> int:
	return mini(SLIME_NEST_BASE_MAX_ACTIVE_SLIMES + slime_nest_growth, SLIME_NEST_HARD_MAX_ACTIVE_SLIMES)

func get_slime_spawn_interval() -> float:
	return maxf(SLIME_NEST_MIN_SPAWN_INTERVAL, SLIME_NEST_BASE_SPAWN_INTERVAL - float(slime_nest_growth) * 0.4)

func get_slime_spawn_summary() -> String:
	return "Slimes %d/%d | Spawned %d | %.1fs" % [
		get_world_slime_count(),
		get_slime_nest_max_active_slimes(),
		maxi(next_world_slime_id - 1, 0),
		get_slime_spawn_interval()
	]

func claim_unclaimed_returned_travelers() -> Array[Dictionary]:
	var claimed: Array[Dictionary] = []
	var claimed_ids: Array[int] = []

	for index in range(returned_travelers.size()):
		var traveler := returned_travelers[index]

		if not bool(traveler.get("town_reentry_claimed", false)):
			traveler["town_reentry_claimed"] = true
			returned_travelers[index] = traveler
			claimed.append(traveler.duplicate(true))
			claimed_ids.append(int(traveler.get("id", -1)))

	for traveler_id in claimed_ids:
		_remove_world_traveler_by_id(traveler_id)

	if not claimed.is_empty():
		state_changed.emit()

	return claimed

func _remove_world_traveler_by_id(traveler_id: int) -> void:
	for index in range(world_travelers.size() - 1, -1, -1):
		if int(world_travelers[index].get("id", -1)) == traveler_id:
			world_travelers.remove_at(index)

func update_returned_traveler_record(traveler_id: int, updated_data: Dictionary) -> void:
	for index in range(returned_travelers.size()):
		if int(returned_travelers[index].get("id", -1)) == traveler_id:
			returned_travelers[index] = updated_data.duplicate(true)
			state_changed.emit()
			return

func get_world_traveler_summary() -> String:
	if world_travelers.is_empty():
		return "None"

	var summary_parts: Array[String] = []

	for traveler in world_travelers:
		var traveler_name := str(traveler.get("display_name", "Traveler"))
		var status := str(traveler.get("status", "Unknown"))
		var trip_count := int(traveler.get("trip_count", 0))
		var max_trip_count := int(traveler.get("max_trip_count", 2))
		var energy := int(traveler.get("energy", DEFAULT_MAX_ENERGY))
		summary_parts.append("%s:%s T%d/%d E%d" % [traveler_name, status, trip_count, max_trip_count, energy])

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
		var trip_count := int(traveler.get("trip_count", 0))
		var max_trip_count := int(traveler.get("max_trip_count", 2))
		var energy := int(traveler.get("energy", DEFAULT_MAX_ENERGY))

		if sale_message != "":
			summary_parts.append("%s:%s T%d/%d E%d %s" % [traveler_name, status, trip_count, max_trip_count, energy, sale_message])
		else:
			summary_parts.append("%s:%s T%d/%d E%d" % [traveler_name, status, trip_count, max_trip_count, energy])

		if summary_parts.size() >= 3:
			break

	if returned_travelers.size() > 3:
		summary_parts.append("+%d more" % (returned_travelers.size() - 3))

	return " | ".join(summary_parts)

func _update_world_slimes(delta: float) -> bool:
	var changed := false
	_slime_spawn_timer += delta

	if get_world_slime_count() < get_slime_nest_max_active_slimes() and _slime_spawn_timer >= get_slime_spawn_interval():
		_spawn_world_slime()
		_slime_spawn_timer = 0.0
		changed = true

	for index in range(world_slimes.size()):
		var slime := world_slimes[index]

		if not bool(slime.get("is_active", true)):
			continue

		var status := str(slime.get("status", "Wandering"))

		if status == "Wandering":
			var target_traveler_id := _find_aggro_target_for_slime(slime)
			if target_traveler_id >= 0:
				slime["status"] = "AggroTraveler"
				slime["target_traveler_id"] = target_traveler_id
				slime["last_event_log"] = "Slime spotted an adventurer."
				changed = true
			else:
				var moved := _move_slime_toward_wander_target(slime, delta)
				changed = moved or changed

		elif status == "AggroTraveler":
			var traveler_index := _find_world_traveler_index_by_id(int(slime.get("target_traveler_id", -1)))
			if traveler_index < 0:
				slime["status"] = "Wandering"
				slime["target_traveler_id"] = -1
				slime["target_position"] = _get_random_slime_wander_position()
				changed = true
			else:
				var traveler := world_travelers[traveler_index]
				var traveler_status := str(traveler.get("status", ""))
				if not _is_outbound_status(traveler_status):
					slime["status"] = "Wandering"
					slime["target_traveler_id"] = -1
					slime["target_position"] = _get_random_slime_wander_position()
					changed = true
				else:
					var traveler_position: Vector2 = traveler.get("world_position", TOWN_WORLD_POSITION)
					var moved_aggro := _move_slime_toward_position(slime, traveler_position, SLIME_AGGRO_SPEED, delta)
					changed = moved_aggro or changed

					if _slime_reached_position(slime, traveler_position, SLIME_CONTACT_DISTANCE):
						traveler["status"] = "FightingSlime"
						traveler["last_combat_log"] = "Slime ambush!"
						_resolve_slime_combat(traveler, int(slime.get("id", -1)), "ambush")
						world_travelers[traveler_index] = traveler
						changed = true

		world_slimes[index] = slime

	_cleanup_inactive_slimes()
	return changed

func _spawn_world_slime() -> Dictionary:
	var spawn_position := _get_random_slime_wander_position()
	var slime := {
		"id": next_world_slime_id,
		"display_name": "Slime %d" % next_world_slime_id,
		"status": "Wandering",
		"world_position": spawn_position,
		"target_position": _get_random_slime_wander_position(),
		"home_position": SLIME_NEST_WORLD_POSITION,
		"target_traveler_id": -1,
		"is_active": true,
		"last_event_log": "Spawned near Slime Nest."
	}

	next_world_slime_id += 1
	world_slimes.append(slime)
	return slime

func _get_random_slime_wander_position() -> Vector2:
	var angle := randf_range(0.0, TAU)
	var distance := randf_range(20.0, SLIME_WANDER_RADIUS)
	return SLIME_NEST_WORLD_POSITION + Vector2(cos(angle), sin(angle)) * distance

func _move_slime_toward_wander_target(slime: Dictionary, delta: float) -> bool:
	var target_position: Vector2 = slime.get("target_position", _get_random_slime_wander_position())
	var moved := _move_slime_toward_position(slime, target_position, SLIME_WANDER_SPEED, delta)

	if _slime_reached_position(slime, target_position, 5.0):
		slime["target_position"] = _get_random_slime_wander_position()
		return true

	return moved

func _move_slime_toward_position(slime: Dictionary, target_position: Vector2, speed: float, delta: float) -> bool:
	var current_position: Vector2 = slime.get("world_position", SLIME_NEST_WORLD_POSITION)
	var new_position := _move_position_toward(current_position, target_position, speed * delta)
	slime["world_position"] = new_position
	slime["target_position"] = target_position
	return current_position != new_position

func _slime_reached_position(slime: Dictionary, target_position: Vector2, distance: float) -> bool:
	var current_position: Vector2 = slime.get("world_position", SLIME_NEST_WORLD_POSITION)
	return current_position.distance_to(target_position) <= distance

func _find_aggro_target_for_slime(slime: Dictionary) -> int:
	var slime_position: Vector2 = slime.get("world_position", SLIME_NEST_WORLD_POSITION)
	var best_traveler_id := -1
	var best_distance := SLIME_AGGRO_RADIUS

	for traveler in world_travelers:
		var traveler_status := str(traveler.get("status", ""))
		if not _is_outbound_status(traveler_status):
			continue

		var traveler_id := int(traveler.get("id", -1))
		if _count_slimes_targeting_traveler(traveler_id) >= MAX_SLIMES_TARGETING_ONE_TRAVELER:
			continue

		var traveler_position: Vector2 = traveler.get("world_position", TOWN_WORLD_POSITION)
		var distance := slime_position.distance_to(traveler_position)
		if distance <= best_distance:
			best_distance = distance
			best_traveler_id = traveler_id

	return best_traveler_id

func _count_slimes_targeting_traveler(traveler_id: int) -> int:
	var count := 0

	for slime in world_slimes:
		if not bool(slime.get("is_active", true)):
			continue

		if str(slime.get("status", "")) == "AggroTraveler" and int(slime.get("target_traveler_id", -1)) == traveler_id:
			count += 1

	return count

func _cleanup_inactive_slimes() -> void:
	var active_slimes: Array[Dictionary] = []
	for slime in world_slimes:
		if bool(slime.get("is_active", true)):
			active_slimes.append(slime)
	world_slimes = active_slimes

func _update_world_travelers(delta: float) -> bool:
	if world_travelers.is_empty():
		return false

	var changed := false

	for index in range(world_travelers.size()):
		var traveler := world_travelers[index]
		var status := str(traveler.get("status", ""))

		if _is_outbound_status(status):
			if _should_return_from_night_risk(traveler):
				changed = true
			else:
				changed = _apply_night_questing_status(traveler) or changed
				var target_slime := _get_target_slime_for_traveler(traveler)

				if not target_slime.is_empty():
					var slime_position: Vector2 = target_slime.get("world_position", SLIME_NEST_WORLD_POSITION)
					traveler["target_slime_id"] = int(target_slime.get("id", -1))
					var moved_to_slime := _move_traveler_toward_target(traveler, slime_position, WORLD_TRAVELER_SPEED, delta)
					changed = moved_to_slime or changed

					if _traveler_reached_position(traveler, slime_position):
						traveler["status"] = "FightingSlime"
						traveler["last_combat_log"] = "Engaged visible Slime."
						_resolve_slime_combat(traveler, int(target_slime.get("id", -1)), "targeted")
						changed = true
				else:
					var moved_to_nest := _move_traveler_toward_target(traveler, SLIME_NEST_WORLD_POSITION, WORLD_TRAVELER_SPEED, delta)
					changed = moved_to_nest or changed

					if _traveler_reached_position(traveler, SLIME_NEST_WORLD_POSITION):
						if status != "SearchingForSlime":
							traveler["status"] = "SearchingForSlime"
							traveler["last_combat_log"] = "At Slime Nest. Waiting for visible Slime."
							changed = true

		elif _is_returning_status(status):
			var moved_back := _move_traveler_toward_target(traveler, TOWN_WORLD_POSITION, WORLD_RETURN_SPEED, delta)
			changed = moved_back or changed

			if _traveler_reached_position(traveler, TOWN_WORLD_POSITION):
				traveler["world_position"] = TOWN_WORLD_POSITION
				_mark_traveler_arrived_at_town(traveler)
				changed = true

		world_travelers[index] = traveler

	return changed

func _is_night() -> bool:
	return GameClock.get_phase_name() == "Night"

func _is_outbound_status(status: String) -> bool:
	return status in [
		"TravelingToSlimeNest",
		"NightQuesting",
        "SearchingForSlime"
	]

func _should_return_from_night_risk(traveler: Dictionary) -> bool:
	if not _is_night():
		return false

	if not allow_night_quests:
		traveler["status"] = "ReturningNightRestricted"
		traveler["target_position"] = TOWN_WORLD_POSITION
		traveler["target_slime_id"] = -1
		traveler["last_combat_log"] = "Night quests disabled. Returning to town."
		return true

	var energy := int(traveler.get("energy", DEFAULT_MAX_ENERGY))
	if energy <= NIGHT_RETREAT_ENERGY_THRESHOLD:
		traveler["status"] = "ReturningLowEnergyAtNight"
		traveler["target_position"] = TOWN_WORLD_POSITION
		traveler["target_slime_id"] = -1
		traveler["last_combat_log"] = "Too tired for Night quest. Returning."
		return true

	return false

func _apply_night_questing_status(traveler: Dictionary) -> bool:
	var status := str(traveler.get("status", ""))
	if _is_night():
		if status != "NightQuesting":
			traveler["status"] = "NightQuesting"
			traveler["last_combat_log"] = "Continuing quest at Night. Danger increased."
			return true
	else:
		if status == "NightQuesting":
			traveler["status"] = "TravelingToSlimeNest"
			traveler["last_combat_log"] = "Day returned. Night danger faded."
			return true

	return false

func _is_returning_status(status: String) -> bool:
	return status in [
		"ReturningWithLoot",
		"InjuredReturning",
		"ReturningLowEnergyAtNight",
        "ReturningNightRestricted"
	]

func _get_target_slime_for_traveler(traveler: Dictionary) -> Dictionary:
	var target_slime_id := int(traveler.get("target_slime_id", -1))
	var existing_target := _get_active_slime_by_id(target_slime_id)
	if not existing_target.is_empty():
		return existing_target

	var traveler_position: Vector2 = traveler.get("world_position", TOWN_WORLD_POSITION)
	return _get_nearest_active_slime(traveler_position)

func _get_active_slime_by_id(slime_id: int) -> Dictionary:
	if slime_id < 0:
		return {}

	for slime in world_slimes:
		if not bool(slime.get("is_active", true)):
			continue

		if int(slime.get("id", -1)) == slime_id:
			return slime

	return {}

func _get_nearest_active_slime(from_position: Vector2) -> Dictionary:
	var best_slime: Dictionary = {}
	var best_distance := 999999.0

	for slime in world_slimes:
		if not bool(slime.get("is_active", true)):
			continue

		var slime_position: Vector2 = slime.get("world_position", SLIME_NEST_WORLD_POSITION)
		var distance := from_position.distance_to(slime_position)

		if distance < best_distance:
			best_distance = distance
			best_slime = slime

	return best_slime

func _find_world_traveler_index_by_id(traveler_id: int) -> int:
	for index in range(world_travelers.size()):
		if int(world_travelers[index].get("id", -1)) == traveler_id:
			return index

	return -1

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
	traveler["target_slime_id"] = -1

	var previous_status := str(traveler.get("status", ""))
	if previous_status == "ReturningWithLoot":
		traveler["status"] = "AwaitingTownReentryWithLoot"
		traveler["last_combat_log"] = "Returned to town with loot. Awaiting re-entry."
	elif previous_status == "InjuredReturning":
		traveler["status"] = "AwaitingTownReentryInjured"
		traveler["last_combat_log"] = "Returned to town injured. Awaiting re-entry."
	elif previous_status == "ReturningLowEnergyAtNight":
		traveler["status"] = "AwaitingTownReentryTired"
		traveler["last_combat_log"] = "Returned from Night due to low energy."
	elif previous_status == "ReturningNightRestricted":
		traveler["status"] = "AwaitingTownReentryNightRestricted"
		traveler["last_combat_log"] = "Returned because Night quests are disabled."
	else:
		traveler["status"] = "AwaitingTownReentry"
		traveler["last_combat_log"] = "Returned to town. Awaiting re-entry."

	returned_travelers.append(traveler.duplicate(true))
	# Do not emit state_changed here; emit after _process safely finishes simulation loops.

func _move_position_toward(current_position: Vector2, target_position: Vector2, max_distance: float) -> Vector2:
	var direction := target_position - current_position
	var distance := direction.length()

	if distance <= max_distance or distance <= 0.0:
		return target_position

	return current_position + direction.normalized() * max_distance

func _resolve_slime_combat(traveler: Dictionary, slime_id: int = -1, encounter_source: String = "") -> void:
	if bool(traveler.get("combat_resolved", false)):
		return

	traveler["combat_resolved"] = true

	var adventurer_hp := int(traveler.get("hp", 30))
	var adventurer_max_hp := int(traveler.get("max_hp", 30))
	var adventurer_attack := int(traveler.get("attack", 7))
	var adventurer_speed := float(traveler.get("speed", 1.0))
	var adventurer_meter := 0.0

	var slime_hp := SLIME_MAX_HP
	var slime_attack := SLIME_ATTACK
	var slime_meter := 0.0
	var night_combat := _is_night()

	if night_combat:
		slime_hp = ceili(float(SLIME_MAX_HP) * NIGHT_SLIME_HP_MULTIPLIER)
		slime_attack = ceili(float(SLIME_ATTACK) * NIGHT_SLIME_ATTACK_MULTIPLIER)
		traveler["last_combat_log"] = "Night combat: Slime empowered."

	var inventory: Dictionary = traveler.get("inventory", {})
	var potion_used := false

	var rounds := 0
	while adventurer_hp > 0 and slime_hp > 0 and rounds < 100:
		rounds += 1
		adventurer_meter += adventurer_speed
		slime_meter += SLIME_SPEED

		if adventurer_hp <= int(adventurer_max_hp * POTION_USE_HP_RATIO) and int(inventory.get(SMALL_POTION_ID, 0)) > 0 and not potion_used:
			inventory[SMALL_POTION_ID] = int(inventory.get(SMALL_POTION_ID, 0)) - 1
			adventurer_hp = mini(adventurer_hp + SMALL_POTION_HEAL_AMOUNT, adventurer_max_hp)
			potion_used = true

		if adventurer_meter >= 1.0:
			adventurer_meter = 0.0
			slime_hp -= adventurer_attack

			if slime_hp <= 0:
				break

		if slime_meter >= 1.0:
			slime_meter = 0.0
			adventurer_hp -= slime_attack

	traveler["hp"] = maxi(adventurer_hp, 0)
	traveler["inventory"] = inventory
	traveler["target_slime_id"] = -1

	var night_note := ""
	if night_combat:
		night_note = " Night danger applied."

	var source_note := ""
	if encounter_source == "ambush":
		source_note = " Ambushed by visible Slime."
	elif encounter_source == "targeted":
		source_note = " Defeated visible Slime."

	if slime_hp <= 0:
		inventory[SLIME_GEL_ID] = int(inventory.get(SLIME_GEL_ID, 0)) + SLIME_GEL_REWARD
		traveler["inventory"] = inventory
		traveler["status"] = "ReturningWithLoot"
		traveler["target_position"] = TOWN_WORLD_POSITION
		traveler["combat_resolved"] = false
		traveler["last_combat_log"] = "Won vs Slime. Returning with %d Slime Gel.%s%s" % [SLIME_GEL_REWARD, night_note, source_note]
		_mark_slime_defeated(slime_id)
	elif adventurer_hp <= 0:
		traveler["status"] = "InjuredReturning"
		traveler["target_position"] = TOWN_WORLD_POSITION
		traveler["combat_resolved"] = false
		traveler["last_combat_log"] = "Lost vs Slime. Returning injured.%s%s" % [night_note, source_note]
		_release_slime_after_combat(slime_id)
	else:
		traveler["status"] = "InjuredReturning"
		traveler["target_position"] = TOWN_WORLD_POSITION
		traveler["combat_resolved"] = false
		traveler["last_combat_log"] = "Combat timed out. Retreating.%s%s" % [night_note, source_note]
		_release_slime_after_combat(slime_id)

	if potion_used:
		traveler["last_combat_log"] += " Potion used."

func _mark_slime_defeated(slime_id: int) -> void:
	if slime_id < 0:
		return

	for index in range(world_slimes.size()):
		if int(world_slimes[index].get("id", -1)) == slime_id:
			var slime := world_slimes[index]
			slime["status"] = "Defeated"
			slime["is_active"] = false
			slime["last_event_log"] = "Defeated by adventurer."
			world_slimes[index] = slime
			return

func _release_slime_after_combat(slime_id: int) -> void:
	if slime_id < 0:
		return

	for index in range(world_slimes.size()):
		if int(world_slimes[index].get("id", -1)) == slime_id:
			var slime := world_slimes[index]
			if bool(slime.get("is_active", true)):
				slime["status"] = "Wandering"
				slime["target_traveler_id"] = -1
				slime["target_position"] = _get_random_slime_wander_position()
				slime["last_event_log"] = "Returned to wandering."
				world_slimes[index] = slime
			return

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
