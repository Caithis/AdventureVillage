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
const SLIME_NEST_HARD_MAX_ACTIVE_SLIMES := 8
const SLIME_NEST_BASE_SPAWN_INTERVAL := 5.0
const SLIME_NEST_MIN_SPAWN_INTERVAL := 1.6
const SLIME_WANDER_RADIUS := 90.0
const SLIME_WANDER_SPEED := 22.0
const SLIME_AGGRO_SPEED := 36.0
const SLIME_AGGRO_RADIUS := 95.0
const SLIME_CONTACT_DISTANCE := 15.0
const MAX_SLIMES_TARGETING_ONE_TRAVELER := 1

const SLIME_HP_GROWTH_PER_LEVEL := 3
const SLIME_ATTACK_GROWTH_PER_TWO_LEVELS := 1
const SLIME_GEL_REWARD_GROWTH_PER_TWO_LEVELS := 1
const SLIME_WANDER_RADIUS_GROWTH_PER_LEVEL := 12.0
const SLIME_AGGRO_RADIUS_GROWTH_PER_LEVEL := 8.0
const SLIME_WANDER_SPEED_GROWTH_PER_LEVEL := 1.5
const SLIME_AGGRO_SPEED_GROWTH_PER_LEVEL := 2.0
const RAID_PRESSURE_GROWTH_WEIGHT := 5
const RAID_PRESSURE_ACTIVE_SLIME_WEIGHT := 3
const RAID_PRESSURE_LEVEL_WEIGHT := 4
const SLIME_DEFEAT_DISPLAY_SECONDS := 1.0

const VISIBLE_COMBAT_CONTACT_DELAY := 0.85
const COMBAT_REENGAGE_COOLDOWN := 1.5
const FLEE_RETURN_SPEED := 82.0
const FLEE_GRACE_SECONDS := 1.1
const FLEE_SAFE_DISTANCE_FROM_TOWN := 140.0
const FLEE_SLIME_AGGRO_RADIUS_MULTIPLIER := 0.45
const MAX_SLIME_RETREAT_CHASES_PER_TRIP := 1
const ADVENTURE_RETREAT_HP_RATIO := 0.50
const MAX_SLIME_KILLS_PER_OUTING := 3

const NIGHT_SLIME_HP_MULTIPLIER := 1.5
const NIGHT_SLIME_ATTACK_MULTIPLIER := 1.5
const NIGHT_RETREAT_ENERGY_THRESHOLD := 40

const SMALL_POTION_HEAL_AMOUNT := 15
const POTION_USE_HP_RATIO := 0.40

const DEFAULT_MAX_ENERGY := 100
const WORLD_TRIP_ENERGY_COST := 45

var money: int = 500
var current_view_name: String = "Unknown"

var economy_shop_sales_income: int = 0
var economy_shop_sales_count: int = 0
var economy_inn_income: int = 0
var economy_inn_visit_count: int = 0
var economy_material_purchase_outflow: int = 0
var economy_material_purchase_count: int = 0
var economy_building_construction_outflow: int = 0
var economy_building_construction_count: int = 0
var economy_upgrade_outflow: int = 0
var economy_upgrade_count: int = 0

const ECONOMY_HISTORY_SAVE_PATH := "user://economy_history.json"
const CORE_STATE_SAVE_VERSION := 1
const ECONOMY_HISTORY_SAVE_VERSION := 1
const WORLD_STATE_SAVE_VERSION := 1

var economy_current_day_number: int = 1
var economy_daily_buckets: Dictionary = {}
var economy_history_loaded: bool = false

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
	var changed: bool = false
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

func record_shop_sale_income(amount: int, item_id: String = "", quantity: int = 1) -> void:
	if amount <= 0:
		return

	var safe_quantity: int = maxi(quantity, 1)
	economy_shop_sales_income += amount
	economy_shop_sales_count += safe_quantity
	_add_to_current_day_bucket("shop_sales_income", amount)
	_add_to_current_day_bucket("shop_sales_count", safe_quantity)
	save_economy_history_to_file(false)
	state_changed.emit()

func record_inn_income(amount: int, service_id: String = "rest", quantity: int = 1) -> void:
	if amount <= 0:
		return

	var safe_quantity: int = maxi(quantity, 1)
	economy_inn_income += amount
	economy_inn_visit_count += safe_quantity
	_add_to_current_day_bucket("inn_income", amount)
	_add_to_current_day_bucket("inn_visit_count", safe_quantity)
	save_economy_history_to_file(false)
	state_changed.emit()

func record_material_purchase_outflow(amount: int, item_id: String = "", quantity: int = 1) -> void:
	if amount <= 0:
		return

	var safe_quantity: int = maxi(quantity, 1)
	economy_material_purchase_outflow += amount
	economy_material_purchase_count += safe_quantity
	_add_to_current_day_bucket("material_purchase_outflow", amount)
	_add_to_current_day_bucket("material_purchase_count", safe_quantity)
	save_economy_history_to_file(false)
	state_changed.emit()

func record_building_construction_outflow(amount: int, building_type: String = "") -> void:
	if amount <= 0:
		return

	economy_building_construction_outflow += amount
	economy_building_construction_count += 1
	_add_to_current_day_bucket("building_construction_outflow", amount)
	_add_to_current_day_bucket("building_construction_count", 1)
	save_economy_history_to_file(false)
	state_changed.emit()

func record_upgrade_outflow(amount: int, building_type: String = "") -> void:
	if amount <= 0:
		return

	economy_upgrade_outflow += amount
	economy_upgrade_count += 1
	_add_to_current_day_bucket("upgrade_outflow", amount)
	_add_to_current_day_bucket("upgrade_count", 1)
	save_economy_history_to_file(false)
	state_changed.emit()

func get_tracked_income_total() -> int:
	return economy_shop_sales_income + economy_inn_income

func get_tracked_outflow_total() -> int:
	return economy_material_purchase_outflow + economy_building_construction_outflow + economy_upgrade_outflow

func get_tracked_net_total() -> int:
	return get_tracked_income_total() - get_tracked_outflow_total()

func get_current_economy_day_number() -> int:
	var clock_node := get_node_or_null("/root/GameClock")
	if clock_node != null:
		return int(clock_node.get("day_number"))

	return economy_current_day_number

func ensure_economy_bucket_for_day(day_number: int) -> void:
	economy_current_day_number = maxi(day_number, 1)

	if not economy_daily_buckets.has(economy_current_day_number):
		economy_daily_buckets[economy_current_day_number] = _create_empty_economy_bucket(economy_current_day_number)

func get_current_day_economy_bucket() -> Dictionary:
	ensure_economy_bucket_for_day(get_current_economy_day_number())
	return economy_daily_buckets[economy_current_day_number]

func get_current_day_income_total() -> int:
	var bucket := get_current_day_economy_bucket()
	return int(bucket.get("shop_sales_income", 0)) + int(bucket.get("inn_income", 0))

func get_current_day_outflow_total() -> int:
	var bucket := get_current_day_economy_bucket()
	return int(bucket.get("material_purchase_outflow", 0)) + int(bucket.get("building_construction_outflow", 0)) + int(bucket.get("upgrade_outflow", 0))

func get_current_day_net_total() -> int:
	return get_current_day_income_total() - get_current_day_outflow_total()

func _add_to_current_day_bucket(key: String, amount: int) -> void:
	var bucket := get_current_day_economy_bucket()
	bucket[key] = int(bucket.get(key, 0)) + amount
	economy_daily_buckets[economy_current_day_number] = bucket

func _create_empty_economy_bucket(day_number: int) -> Dictionary:
	return {
		"day_number": day_number,
		"shop_sales_income": 0,
		"shop_sales_count": 0,
		"inn_income": 0,
		"inn_visit_count": 0,
		"material_purchase_outflow": 0,
		"material_purchase_count": 0,
		"building_construction_outflow": 0,
		"building_construction_count": 0,
		"upgrade_outflow": 0,
		"upgrade_count": 0,
	}

func reset_economy_event_totals() -> void:
	economy_shop_sales_income = 0
	economy_shop_sales_count = 0
	economy_inn_income = 0
	economy_inn_visit_count = 0
	economy_material_purchase_outflow = 0
	economy_material_purchase_count = 0
	economy_building_construction_outflow = 0
	economy_building_construction_count = 0
	economy_upgrade_outflow = 0
	economy_upgrade_count = 0
	economy_daily_buckets.clear()
	ensure_economy_bucket_for_day(get_current_economy_day_number())
	save_economy_history_to_file(false)
	state_changed.emit()



func save_core_state_to_file(show_warning: bool = true) -> bool:
	var save_manager: Node = get_node_or_null("/root/SaveManager")

	if save_manager == null or not save_manager.has_method("save_core_state_data"):
		if show_warning:
			push_warning("Failed to save core state. SaveManager unavailable.")
		return false

	return bool(save_manager.save_core_state_data(get_core_state_save_data(), show_warning))

func load_core_state_from_file(show_warning: bool = true) -> bool:
	var save_manager: Node = get_node_or_null("/root/SaveManager")

	if save_manager == null or not save_manager.has_method("load_core_state_data"):
		if show_warning:
			push_warning("Failed to load core state. SaveManager unavailable.")
		return false

	var save_data: Dictionary = save_manager.load_core_state_data(show_warning)
	if save_data.is_empty():
		return false

	return apply_core_state_save_data(save_data, show_warning)

func get_core_state_save_data() -> Dictionary:
	return {
		"version": CORE_STATE_SAVE_VERSION,
		"money": money,
		"current_view_name": current_view_name,
		"town_inventory": _serialize_town_inventory(),
		"allow_night_quests": allow_night_quests,
		"general_store_buys_slime_gel": general_store_buys_slime_gel
	}

func apply_core_state_save_data(save_data: Dictionary, show_warning: bool = true) -> bool:
	if save_data.is_empty():
		if show_warning:
			push_warning("Core state save data is empty.")
		return false

	money = int(save_data.get("money", money))
	current_view_name = str(save_data.get("current_view_name", current_view_name))
	allow_night_quests = bool(save_data.get("allow_night_quests", allow_night_quests))
	general_store_buys_slime_gel = bool(save_data.get("general_store_buys_slime_gel", general_store_buys_slime_gel))

	var raw_inventory: Variant = save_data.get("town_inventory", {})
	if raw_inventory is Dictionary:
		town_inventory.clear()
		var inventory_dict: Dictionary = raw_inventory as Dictionary
		for item_id in inventory_dict.keys():
			town_inventory[str(item_id)] = maxi(0, int(inventory_dict.get(item_id, 0)))

	if not town_inventory.has(SMALL_POTION_ID):
		town_inventory[SMALL_POTION_ID] = 0
	if not town_inventory.has(SLIME_GEL_ID):
		town_inventory[SLIME_GEL_ID] = 0

	state_changed.emit()
	return true

func get_core_state_status_text() -> String:
	return "Gold: %dg\nPotions: %d\nSlime Gel: %d\nNight Quests: %s\nStore Buying Slime Gel: %s" % [
		money,
		get_item_count(SMALL_POTION_ID),
		get_item_count(SLIME_GEL_ID),
		get_night_quest_policy_text(),
		"Yes" if general_store_buys_slime_gel else "No"
	]

func _serialize_town_inventory() -> Dictionary:
	var output: Dictionary = {}

	for item_id in town_inventory.keys():
		output[str(item_id)] = int(town_inventory.get(item_id, 0))

	return output

func save_economy_history_to_file(show_warning: bool = true) -> bool:
	var save_data: Dictionary = get_economy_history_save_data()
	var save_manager := get_node_or_null("/root/SaveManager")

	if save_manager == null or not save_manager.has_method("save_economy_history_data"):
		if show_warning:
			push_warning("Failed to save economy history. SaveManager unavailable.")
		return false

	return bool(save_manager.save_economy_history_data(save_data, show_warning))

func get_economy_history_save_data() -> Dictionary:
	return {
		"version": ECONOMY_HISTORY_SAVE_VERSION,
		"current_day_number": economy_current_day_number,
		"session_totals": {
			"shop_sales_income": economy_shop_sales_income,
			"shop_sales_count": economy_shop_sales_count,
			"inn_income": economy_inn_income,
			"inn_visit_count": economy_inn_visit_count,
			"material_purchase_outflow": economy_material_purchase_outflow,
			"material_purchase_count": economy_material_purchase_count,
			"building_construction_outflow": economy_building_construction_outflow,
			"building_construction_count": economy_building_construction_count,
			"upgrade_outflow": economy_upgrade_outflow,
			"upgrade_count": economy_upgrade_count,
		},
		"daily_buckets": _serialize_economy_daily_buckets()
	}

func load_economy_history_from_file(show_warning: bool = true) -> bool:
	var save_manager := get_node_or_null("/root/SaveManager")

	if save_manager == null or not save_manager.has_method("load_economy_history_data"):
		if show_warning:
			push_warning("Failed to load economy history. SaveManager unavailable.")
		ensure_economy_bucket_for_day(get_current_economy_day_number())
		economy_history_loaded = true
		return false

	var save_data: Dictionary = save_manager.load_economy_history_data(show_warning)
	if save_data.is_empty():
		ensure_economy_bucket_for_day(get_current_economy_day_number())
		economy_history_loaded = true
		return false

	return apply_economy_history_save_data(save_data, show_warning)

func apply_economy_history_save_data(save_data: Dictionary, show_warning: bool = true) -> bool:
	if save_data.is_empty():
		ensure_economy_bucket_for_day(get_current_economy_day_number())
		economy_history_loaded = true
		return false

	var totals: Dictionary = save_data.get("session_totals", {})

	economy_shop_sales_income = int(totals.get("shop_sales_income", 0))
	economy_shop_sales_count = int(totals.get("shop_sales_count", 0))
	economy_inn_income = int(totals.get("inn_income", 0))
	economy_inn_visit_count = int(totals.get("inn_visit_count", 0))
	economy_material_purchase_outflow = int(totals.get("material_purchase_outflow", 0))
	economy_material_purchase_count = int(totals.get("material_purchase_count", 0))
	economy_building_construction_outflow = int(totals.get("building_construction_outflow", 0))
	economy_building_construction_count = int(totals.get("building_construction_count", 0))
	economy_upgrade_outflow = int(totals.get("upgrade_outflow", 0))
	economy_upgrade_count = int(totals.get("upgrade_count", 0))

	economy_current_day_number = maxi(int(save_data.get("current_day_number", get_current_economy_day_number())), 1)
	economy_daily_buckets = _deserialize_economy_daily_buckets(save_data.get("daily_buckets", []))
	ensure_economy_bucket_for_day(get_current_economy_day_number())

	economy_history_loaded = true
	state_changed.emit()
	return true

func _serialize_economy_daily_buckets() -> Array[Dictionary]:
	var serialized: Array[Dictionary] = []
	var day_numbers: Array[int] = []

	for key in economy_daily_buckets.keys():
		day_numbers.append(int(key))

	day_numbers.sort()

	for day_number in day_numbers:
		var bucket: Dictionary = economy_daily_buckets.get(day_number, _create_empty_economy_bucket(day_number))
		serialized.append(bucket.duplicate(true))

	return serialized

func _deserialize_economy_daily_buckets(raw_buckets: Variant) -> Dictionary:
	var result: Dictionary = {}

	if not raw_buckets is Array:
		return result

	for raw_bucket in raw_buckets:
		if not raw_bucket is Dictionary:
			continue

		var bucket: Dictionary = raw_bucket as Dictionary
		var day_number: int = maxi(int(bucket.get("day_number", 1)), 1)
		var normalized_bucket: Dictionary = _create_empty_economy_bucket(day_number)

		for key in normalized_bucket.keys():
			normalized_bucket[key] = int(bucket.get(key, normalized_bucket[key]))

		result[day_number] = normalized_bucket

	return result

func get_previous_day_number() -> int:
	return maxi(get_current_economy_day_number() - 1, 1)

func get_previous_day_economy_bucket() -> Dictionary:
	var previous_day: int = get_previous_day_number()

	if economy_daily_buckets.has(previous_day):
		return economy_daily_buckets[previous_day]

	return _create_empty_economy_bucket(previous_day)

func get_bucket_income_total(bucket: Dictionary) -> int:
	return int(bucket.get("shop_sales_income", 0)) + int(bucket.get("inn_income", 0))

func get_bucket_outflow_total(bucket: Dictionary) -> int:
	return int(bucket.get("material_purchase_outflow", 0)) + int(bucket.get("building_construction_outflow", 0)) + int(bucket.get("upgrade_outflow", 0))

func get_bucket_net_total(bucket: Dictionary) -> int:
	return get_bucket_income_total(bucket) - get_bucket_outflow_total(bucket)

func get_trend_direction_text(current_value: int, previous_value: int, positive_when_higher: bool = true) -> String:
	if current_value == previous_value:
		return "Flat"

	var improved: bool = current_value > previous_value
	if not positive_when_higher:
		improved = current_value < previous_value

	if improved:
		return "Up"

	return "Down"

func add_item(item_id: String, amount: int) -> void:
	if amount <= 0:
		return

	town_inventory[item_id] = get_item_count(item_id) + amount
	state_changed.emit()

func remove_item(item_id: String, amount: int) -> bool:
	if amount <= 0:
		return false

	var current_amount: int = get_item_count(item_id)
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

	var traveler: Dictionary = {
		"id": next_world_traveler_id,
		"display_name": _safe_get_property(adventurer, "display_name", "Unknown"),
		"class_id": _safe_get_property(adventurer, "class_id", "fighter"),
		"level": _safe_get_property(adventurer, "level", 1),
		"gold": _safe_get_property(adventurer, "gold", 0),
		"inventory": _safe_get_property(adventurer, "inventory", {}).duplicate(true),
		"trip_count": _safe_get_property(adventurer, "trip_count", 0),
		"max_trip_count": _safe_get_property(adventurer, "max_trip_count", 2),
		"slime_kills_this_outing": 0,
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
		"combat_contact_timer": 0.0,
		"combat_cooldown_timer": 0.0,
		"flee_grace_timer": 0.0,
		"slime_chases_during_retreat": 0,
		"encounter_source": "",
		"has_returned_to_town": false,
		"town_reentry_claimed": false,
		"sale_message": "",
		"floating_event_text": "",
		"last_damage_taken": 0,
		"last_damage_dealt": 0,
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
	var visible_slimes: Array[Dictionary] = []
	for slime in world_slimes:
		if bool(slime.get("is_active", true)):
			visible_slimes.append(slime)
	return visible_slimes

func get_world_slime_count() -> int:
	var count: int = 0
	for slime in world_slimes:
		if bool(slime.get("is_active", true)) and str(slime.get("status", "")) != "Defeated":
			count += 1
	return count

func get_slime_nest_level() -> int:
	return maxi(1, 1 + floori(float(slime_nest_growth) / 2.0))

func get_slime_nest_max_active_slimes() -> int:
	var level: int = get_slime_nest_level()
	var growth_bonus: int = floori(float(slime_nest_growth) / 3.0)
	return mini(SLIME_NEST_HARD_MAX_ACTIVE_SLIMES, maxi(3, SLIME_NEST_BASE_MAX_ACTIVE_SLIMES + level - 1 + growth_bonus))

func get_slime_spawn_interval() -> float:
	var level: int = get_slime_nest_level()
	var growth_pressure: float = float(slime_nest_growth) * 0.35
	var level_pressure: float = float(level - 1) * 0.25
	return maxf(SLIME_NEST_MIN_SPAWN_INTERVAL, SLIME_NEST_BASE_SPAWN_INTERVAL - growth_pressure - level_pressure)

func get_current_slime_max_hp() -> int:
	return SLIME_MAX_HP + (get_slime_nest_level() - 1) * SLIME_HP_GROWTH_PER_LEVEL

func get_current_slime_attack() -> int:
	return SLIME_ATTACK + floori(float(get_slime_nest_level() - 1) / 2.0) * SLIME_ATTACK_GROWTH_PER_TWO_LEVELS

func get_current_slime_gel_reward() -> int:
	return SLIME_GEL_REWARD + floori(float(get_slime_nest_level() - 1) / 2.0) * SLIME_GEL_REWARD_GROWTH_PER_TWO_LEVELS

func get_current_slime_wander_radius() -> float:
	return SLIME_WANDER_RADIUS + float(get_slime_nest_level() - 1) * SLIME_WANDER_RADIUS_GROWTH_PER_LEVEL

func get_current_slime_aggro_radius() -> float:
	return SLIME_AGGRO_RADIUS + float(get_slime_nest_level() - 1) * SLIME_AGGRO_RADIUS_GROWTH_PER_LEVEL

func get_current_slime_wander_speed() -> float:
	return SLIME_WANDER_SPEED + float(get_slime_nest_level() - 1) * SLIME_WANDER_SPEED_GROWTH_PER_LEVEL

func get_current_slime_aggro_speed() -> float:
	return SLIME_AGGRO_SPEED + float(get_slime_nest_level() - 1) * SLIME_AGGRO_SPEED_GROWTH_PER_LEVEL

func get_raid_pressure_score() -> int:
	return slime_nest_growth * RAID_PRESSURE_GROWTH_WEIGHT + get_world_slime_count() * RAID_PRESSURE_ACTIVE_SLIME_WEIGHT + get_slime_nest_level() * RAID_PRESSURE_LEVEL_WEIGHT

func get_raid_pressure_state() -> String:
	var pressure: int = get_raid_pressure_score()

	if pressure < 20:
		return "Quiet"

	if pressure < 40:
		return "Watch"

	if pressure < 65:
		return "High"

	return "Raid Risk"

func get_slime_spawn_summary() -> String:
	return "L%d %s | Slimes %d/%d | %.1fs | HP %d ATK %d | Raid %d" % [
		get_slime_nest_level(),
		get_raid_pressure_state(),
		get_world_slime_count(),
		get_slime_nest_max_active_slimes(),
		get_slime_spawn_interval(),
		get_current_slime_max_hp(),
		get_current_slime_attack(),
		get_raid_pressure_score()
	]

func claim_unclaimed_returned_travelers() -> Array[Dictionary]:
	var claimed: Array[Dictionary] = []
	var claimed_ids: Array[int] = []

	for index in range(returned_travelers.size()):
		var traveler: Dictionary = returned_travelers[index]

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
		var traveler_name: String = str(traveler.get("display_name", "Traveler"))
		var status: String = str(traveler.get("status", "Unknown"))
		var trip_count: int = int(traveler.get("trip_count", 0))
		var max_trip_count: int = int(traveler.get("max_trip_count", 2))
		var energy: int = int(traveler.get("energy", DEFAULT_MAX_ENERGY))
		var kills: int = int(traveler.get("slime_kills_this_outing", 0))
		summary_parts.append("%s:%s T%d/%d E%d K%d" % [traveler_name, status, trip_count, max_trip_count, energy, kills])

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
		var traveler_name: String = str(traveler.get("display_name", "Traveler"))
		var status: String = str(traveler.get("status", "Returned"))
		var sale_message: String = str(traveler.get("sale_message", ""))
		var trip_count: int = int(traveler.get("trip_count", 0))
		var max_trip_count: int = int(traveler.get("max_trip_count", 2))
		var energy: int = int(traveler.get("energy", DEFAULT_MAX_ENERGY))

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
	var changed: bool = false
	_slime_spawn_timer += delta

	if get_world_slime_count() < get_slime_nest_max_active_slimes() and _slime_spawn_timer >= get_slime_spawn_interval():
		_spawn_world_slime()
		_slime_spawn_timer = 0.0
		changed = true

	for index in range(world_slimes.size()):
		var slime: Dictionary = world_slimes[index]

		if not bool(slime.get("is_active", true)):
			continue

		var status: String = str(slime.get("status", "Wandering"))

		if status == "Defeated":
			slime["defeat_timer"] = float(slime.get("defeat_timer", SLIME_DEFEAT_DISPLAY_SECONDS)) - delta
			if float(slime.get("defeat_timer", 0.0)) <= 0.0:
				slime["is_active"] = false
			changed = true

		elif status == "Engaged":
			pass

		elif status == "Wandering":
			var target_traveler_id: int = _find_aggro_target_for_slime(slime)
			if target_traveler_id >= 0:
				slime["status"] = "AggroTraveler"
				slime["target_traveler_id"] = target_traveler_id
				slime["last_event_log"] = "Slime spotted an adventurer."
				changed = true
			else:
				var moved: bool = _move_slime_toward_wander_target(slime, delta)
				changed = moved or changed

		elif status == "AggroTraveler":
			var traveler_index: int = _find_world_traveler_index_by_id(int(slime.get("target_traveler_id", -1)))
			if traveler_index < 0:
				_release_slime_to_wander(slime)
				changed = true
			else:
				var traveler: Dictionary = world_travelers[traveler_index]
				if not _can_slime_continue_targeting_traveler(slime, traveler):
					_release_slime_to_wander(slime)
					changed = true
				else:
					var traveler_position: Vector2 = traveler.get("world_position", TOWN_WORLD_POSITION)
					var moved_aggro: bool = _move_slime_toward_position(slime, traveler_position, get_current_slime_aggro_speed(), delta)
					changed = moved_aggro or changed

					if _slime_reached_position(slime, traveler_position, SLIME_CONTACT_DISTANCE):
						_start_visible_slime_combat(traveler, int(slime.get("id", -1)), "ambush")
						world_travelers[traveler_index] = traveler
						slime["status"] = "Engaged"
						slime["last_event_log"] = "Engaged traveler."
						changed = true

		world_slimes[index] = slime

	_cleanup_inactive_slimes()
	return changed

func _spawn_world_slime() -> Dictionary:
	var spawn_position: Vector2 = _get_random_slime_wander_position()
	var slime: Dictionary = {
		"id": next_world_slime_id,
		"display_name": "Slime %d" % next_world_slime_id,
		"level": get_slime_nest_level(),
		"max_hp": get_current_slime_max_hp(),
		"attack": get_current_slime_attack(),
		"status": "Wandering",
		"world_position": spawn_position,
		"target_position": _get_random_slime_wander_position(),
		"home_position": SLIME_NEST_WORLD_POSITION,
		"target_traveler_id": -1,
		"is_active": true,
		"defeat_timer": 0.0,
		"last_event_log": "Spawned near Slime Nest."
	}

	next_world_slime_id += 1
	world_slimes.append(slime)
	return slime

func _get_random_slime_wander_position() -> Vector2:
	var angle: float = randf_range(0.0, TAU)
	var distance: float = randf_range(20.0, get_current_slime_wander_radius())
	return SLIME_NEST_WORLD_POSITION + Vector2(cos(angle), sin(angle)) * distance

func _move_slime_toward_wander_target(slime: Dictionary, delta: float) -> bool:
	var target_position: Vector2 = slime.get("target_position", _get_random_slime_wander_position())
	var moved: bool = _move_slime_toward_position(slime, target_position, get_current_slime_wander_speed(), delta)

	if _slime_reached_position(slime, target_position, 5.0):
		slime["target_position"] = _get_random_slime_wander_position()
		return true

	return moved

func _move_slime_toward_position(slime: Dictionary, target_position: Vector2, speed: float, delta: float) -> bool:
	var current_position: Vector2 = slime.get("world_position", SLIME_NEST_WORLD_POSITION)
	var new_position: Vector2 = _move_position_toward(current_position, target_position, speed * delta)
	slime["world_position"] = new_position
	slime["target_position"] = target_position
	return current_position != new_position

func _slime_reached_position(slime: Dictionary, target_position: Vector2, distance: float) -> bool:
	var current_position: Vector2 = slime.get("world_position", SLIME_NEST_WORLD_POSITION)
	return current_position.distance_to(target_position) <= distance

func _find_aggro_target_for_slime(slime: Dictionary) -> int:
	var slime_position: Vector2 = slime.get("world_position", SLIME_NEST_WORLD_POSITION)
	var best_traveler_id: int = -1
	var best_distance: float = 999999.0

	for traveler in world_travelers:
		if not _can_slime_target_traveler(traveler):
			continue

		var traveler_id: int = int(traveler.get("id", -1))
		if _count_slimes_targeting_traveler(traveler_id) >= MAX_SLIMES_TARGETING_ONE_TRAVELER:
			continue

		var traveler_position: Vector2 = traveler.get("world_position", TOWN_WORLD_POSITION)
		var distance: float = slime_position.distance_to(traveler_position)
		var max_target_distance: float = _get_slime_aggro_radius_for_traveler(traveler)

		if distance <= max_target_distance and distance < best_distance:
			best_distance = distance
			best_traveler_id = traveler_id

	return best_traveler_id

func _can_slime_target_traveler(traveler: Dictionary) -> bool:
	if float(traveler.get("combat_cooldown_timer", 0.0)) > 0.0:
		return false

	if float(traveler.get("flee_grace_timer", 0.0)) > 0.0:
		return false

	var traveler_status: String = str(traveler.get("status", ""))

	if _is_outbound_status(traveler_status):
		return true

	if _is_returning_status(traveler_status):
		return _can_slime_chase_returning_traveler(traveler)

	return false

func _can_slime_continue_targeting_traveler(slime: Dictionary, traveler: Dictionary) -> bool:
	if str(slime.get("status", "")) != "AggroTraveler":
		return false

	return _can_slime_target_traveler(traveler)

func _get_slime_aggro_radius_for_traveler(traveler: Dictionary) -> float:
	var traveler_status: String = str(traveler.get("status", ""))

	if _is_returning_status(traveler_status):
		return get_current_slime_aggro_radius() * FLEE_SLIME_AGGRO_RADIUS_MULTIPLIER

	return get_current_slime_aggro_radius()

func _can_slime_chase_returning_traveler(traveler: Dictionary) -> bool:
	if not _is_traveler_weakened_for_retreat_danger(traveler):
		return false

	if int(traveler.get("slime_chases_during_retreat", 0)) >= MAX_SLIME_RETREAT_CHASES_PER_TRIP:
		return false

	var traveler_position: Vector2 = traveler.get("world_position", TOWN_WORLD_POSITION)
	if traveler_position.distance_to(TOWN_WORLD_POSITION) <= FLEE_SAFE_DISTANCE_FROM_TOWN:
		return false

	return true

func _is_traveler_weakened_for_retreat_danger(traveler: Dictionary) -> bool:
	var hp: int = int(traveler.get("hp", 0))
	var max_hp: int = int(traveler.get("max_hp", 30))
	return hp <= _get_retreat_hp_threshold(max_hp)

func _get_retreat_hp_threshold(max_hp: int) -> int:
	return ceili(float(max_hp) * ADVENTURE_RETREAT_HP_RATIO)

func _count_slimes_targeting_traveler(traveler_id: int) -> int:
	var count: int = 0

	for slime in world_slimes:
		if not bool(slime.get("is_active", true)):
			continue

		var status: String = str(slime.get("status", ""))
		if (status == "AggroTraveler" or status == "Engaged") and int(slime.get("target_traveler_id", -1)) == traveler_id:
			count += 1

	return count

func _release_slime_to_wander(slime: Dictionary) -> void:
	slime["status"] = "Wandering"
	slime["target_traveler_id"] = -1
	slime["target_position"] = _get_random_slime_wander_position()
	slime["last_event_log"] = "Returned to wandering."

func _cleanup_inactive_slimes() -> void:
	var active_slimes: Array[Dictionary] = []
	for slime in world_slimes:
		if bool(slime.get("is_active", true)):
			active_slimes.append(slime)
	world_slimes = active_slimes

func _update_world_travelers(delta: float) -> bool:
	if world_travelers.is_empty():
		return false

	var changed: bool = false

	for index in range(world_travelers.size()):
		var traveler: Dictionary = world_travelers[index]
		_tick_traveler_timers(traveler, delta)

		var status: String = str(traveler.get("status", ""))

		if _is_outbound_status(status) and _should_flee_from_low_hp(traveler):
			changed = true
			status = str(traveler.get("status", ""))

		if status == "FightingVisibleSlime":
			traveler["combat_contact_timer"] = float(traveler.get("combat_contact_timer", 0.0)) - delta
			changed = true

			if float(traveler.get("combat_contact_timer", 0.0)) <= 0.0:
				_resolve_slime_combat(
					traveler,
					int(traveler.get("target_slime_id", -1)),
					str(traveler.get("encounter_source", "targeted"))
				)
				changed = true

		elif _is_outbound_status(status):
			if _should_return_from_night_risk(traveler):
				changed = true
			elif float(traveler.get("combat_cooldown_timer", 0.0)) > 0.0:
				if str(traveler.get("last_combat_log", "")) != "Catching breath before re-engaging.":
					traveler["last_combat_log"] = "Catching breath before re-engaging."
					traveler["floating_event_text"] = "Cooldown"
					changed = true
			else:
				changed = _apply_night_questing_status(traveler) or changed
				var target_slime: Dictionary = _get_target_slime_for_traveler(traveler)

				if not target_slime.is_empty():
					var slime_position: Vector2 = target_slime.get("world_position", SLIME_NEST_WORLD_POSITION)
					traveler["target_slime_id"] = int(target_slime.get("id", -1))
					var moved_to_slime: bool = _move_traveler_toward_target(traveler, slime_position, WORLD_TRAVELER_SPEED, delta)
					changed = moved_to_slime or changed

					if _traveler_reached_position(traveler, slime_position):
						_start_visible_slime_combat(traveler, int(target_slime.get("id", -1)), "targeted")
						_mark_slime_engaged(int(target_slime.get("id", -1)), int(traveler.get("id", -1)))
						changed = true
				else:
					var moved_to_nest: bool = _move_traveler_toward_target(traveler, SLIME_NEST_WORLD_POSITION, WORLD_TRAVELER_SPEED, delta)
					changed = moved_to_nest or changed

					if _traveler_reached_position(traveler, SLIME_NEST_WORLD_POSITION):
						if status != "SearchingForSlime":
							traveler["status"] = "SearchingForSlime"
							traveler["last_combat_log"] = "At Slime Nest. Waiting for visible Slime."
							traveler["floating_event_text"] = "Searching..."
							changed = true

		elif _is_returning_status(status):
			var return_speed: float = _get_return_speed_for_status(status)
			var moved_back: bool = _move_traveler_toward_target(traveler, TOWN_WORLD_POSITION, return_speed, delta)
			changed = moved_back or changed

			if _traveler_reached_position(traveler, TOWN_WORLD_POSITION):
				traveler["world_position"] = TOWN_WORLD_POSITION
				_mark_traveler_arrived_at_town(traveler)
				changed = true

		world_travelers[index] = traveler

	return changed

func _tick_traveler_timers(traveler: Dictionary, delta: float) -> void:
	var cooldown: float = float(traveler.get("combat_cooldown_timer", 0.0))
	if cooldown > 0.0:
		traveler["combat_cooldown_timer"] = maxf(cooldown - delta, 0.0)

	var flee_grace: float = float(traveler.get("flee_grace_timer", 0.0))
	if flee_grace > 0.0:
		traveler["flee_grace_timer"] = maxf(flee_grace - delta, 0.0)

func _is_night() -> bool:
	return GameClock.get_phase_name() == "Night"

func _is_outbound_status(status: String) -> bool:
	return status in [
		"TravelingToSlimeNest",
		"NightQuesting",
		"SearchingForSlime",
        "SeekingNextSlime"
	]

func _should_return_from_night_risk(traveler: Dictionary) -> bool:
	if not _is_night():
		return false

	if not allow_night_quests:
		traveler["status"] = "ReturningNightRestricted"
		traveler["target_position"] = TOWN_WORLD_POSITION
		traveler["target_slime_id"] = -1
		traveler["last_combat_log"] = "Night quests disabled. Returning to town."
		traveler["floating_event_text"] = "Night Quests Off"
		return true

	var energy: int = int(traveler.get("energy", DEFAULT_MAX_ENERGY))
	if energy <= NIGHT_RETREAT_ENERGY_THRESHOLD:
		traveler["status"] = "ReturningLowEnergyAtNight"
		traveler["target_position"] = TOWN_WORLD_POSITION
		traveler["target_slime_id"] = -1
		traveler["flee_grace_timer"] = FLEE_GRACE_SECONDS
		traveler["last_combat_log"] = "Too tired for Night quest. Returning."
		traveler["floating_event_text"] = "Too Tired - Return"
		return true

	return false

func _apply_night_questing_status(traveler: Dictionary) -> bool:
	var status: String = str(traveler.get("status", ""))
	if _is_night():
		if status != "NightQuesting":
			traveler["status"] = "NightQuesting"
			traveler["last_combat_log"] = "Continuing quest at Night. Danger increased."
			traveler["floating_event_text"] = "Night Quest"
			return true
	else:
		if status == "NightQuesting":
			traveler["status"] = "TravelingToSlimeNest"
			traveler["last_combat_log"] = "Day returned. Night danger faded."
			traveler["floating_event_text"] = "Day Returned"
			return true

	return false

func _is_returning_status(status: String) -> bool:
	return status in [
		"ReturningWithLoot",
		"InjuredReturning",
		"FleeingToTown",
		"ReturningLowEnergyAtNight",
        "ReturningNightRestricted"
	]

func _get_return_speed_for_status(status: String) -> float:
	if status == "FleeingToTown" or status == "InjuredReturning" or status == "ReturningLowEnergyAtNight":
		return FLEE_RETURN_SPEED

	return WORLD_RETURN_SPEED

func _should_flee_from_low_hp(traveler: Dictionary) -> bool:
	if not _is_traveler_weakened_for_retreat_danger(traveler):
		return false

	var status: String = str(traveler.get("status", ""))
	if status == "FleeingToTown":
		return false

	_send_traveler_fleeing_to_town(traveler, "HP low. Fleeing to town.")
	return true

func _send_traveler_fleeing_to_town(traveler: Dictionary, message: String) -> void:
	traveler["status"] = "FleeingToTown"
	traveler["target_position"] = TOWN_WORLD_POSITION
	traveler["target_slime_id"] = -1
	traveler["flee_grace_timer"] = FLEE_GRACE_SECONDS
	traveler["last_combat_log"] = message
	traveler["floating_event_text"] = "Flee!"

func _get_target_slime_for_traveler(traveler: Dictionary) -> Dictionary:
	var traveler_id: int = int(traveler.get("id", -1))
	var target_slime_id: int = int(traveler.get("target_slime_id", -1))
	var existing_target: Dictionary = _get_active_slime_by_id(target_slime_id, traveler_id)
	if not existing_target.is_empty():
		return existing_target

	var traveler_position: Vector2 = traveler.get("world_position", TOWN_WORLD_POSITION)
	return _get_nearest_available_slime(traveler_position, traveler_id)

func _get_active_slime_by_id(slime_id: int, traveler_id: int = -1) -> Dictionary:
	if slime_id < 0:
		return {}

	for slime in world_slimes:
		if not _is_slime_available_for_traveler(slime, traveler_id):
			continue

		if int(slime.get("id", -1)) == slime_id:
			return slime

	return {}

func _get_nearest_available_slime(from_position: Vector2, traveler_id: int) -> Dictionary:
	var best_slime: Dictionary = {}
	var best_distance: float = 999999.0

	for slime in world_slimes:
		if not _is_slime_available_for_traveler(slime, traveler_id):
			continue

		var slime_position: Vector2 = slime.get("world_position", SLIME_NEST_WORLD_POSITION)
		var distance: float = from_position.distance_to(slime_position)

		if distance < best_distance:
			best_distance = distance
			best_slime = slime

	return best_slime

func _is_slime_available_for_traveler(slime: Dictionary, traveler_id: int) -> bool:
	if not bool(slime.get("is_active", true)):
		return false

	var status: String = str(slime.get("status", ""))
	if status == "Defeated" or status == "Engaged":
		return false

	if status == "AggroTraveler" and int(slime.get("target_traveler_id", -1)) != traveler_id:
		return false

	return true

func _find_world_traveler_index_by_id(traveler_id: int) -> int:
	for index in range(world_travelers.size()):
		if int(world_travelers[index].get("id", -1)) == traveler_id:
			return index

	return -1

func _move_traveler_toward_target(traveler: Dictionary, target_position: Vector2, speed: float, delta: float) -> bool:
	var current_position: Vector2 = traveler.get("world_position", TOWN_WORLD_POSITION)
	var new_position: Vector2 = _move_position_toward(current_position, target_position, speed * delta)
	traveler["target_position"] = target_position
	traveler["world_position"] = new_position
	return current_position != new_position

func _traveler_reached_position(traveler: Dictionary, target_position: Vector2) -> bool:
	var current_position: Vector2 = traveler.get("world_position", TOWN_WORLD_POSITION)
	return current_position.distance_to(target_position) <= WORLD_ARRIVAL_DISTANCE

func _start_visible_slime_combat(traveler: Dictionary, slime_id: int, encounter_source: String) -> void:
	var previous_status: String = str(traveler.get("status", ""))

	if _is_returning_status(previous_status):
		traveler["slime_chases_during_retreat"] = int(traveler.get("slime_chases_during_retreat", 0)) + 1

	traveler["status"] = "FightingVisibleSlime"
	traveler["target_slime_id"] = slime_id
	traveler["encounter_source"] = encounter_source
	traveler["combat_contact_timer"] = VISIBLE_COMBAT_CONTACT_DELAY
	traveler["last_combat_log"] = "Combat contact with visible Slime."
	traveler["floating_event_text"] = "Combat!"

func _mark_slime_engaged(slime_id: int, traveler_id: int) -> void:
	for index in range(world_slimes.size()):
		if int(world_slimes[index].get("id", -1)) == slime_id:
			var slime: Dictionary = world_slimes[index]
			if bool(slime.get("is_active", true)) and str(slime.get("status", "")) != "Defeated":
				slime["status"] = "Engaged"
				slime["target_traveler_id"] = traveler_id
				slime["last_event_log"] = "Engaged traveler."
				world_slimes[index] = slime
			return

func _mark_traveler_arrived_at_town(traveler: Dictionary) -> void:
	if bool(traveler.get("has_returned_to_town", false)):
		return

	traveler["has_returned_to_town"] = true
	traveler["target_slime_id"] = -1

	var previous_status: String = str(traveler.get("status", ""))
	if previous_status == "ReturningWithLoot":
		traveler["status"] = "AwaitingTownReentryWithLoot"
		traveler["last_combat_log"] = "Returned to town with loot. Awaiting re-entry."
	elif previous_status == "InjuredReturning":
		traveler["status"] = "AwaitingTownReentryInjured"
		traveler["last_combat_log"] = "Returned to town injured. Awaiting re-entry."
	elif previous_status == "FleeingToTown":
		traveler["status"] = "AwaitingTownReentryFled"
		traveler["last_combat_log"] = "Fled back to town. Awaiting re-entry."
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

func _move_position_toward(current_position: Vector2, target_position: Vector2, max_distance: float) -> Vector2:
	var direction: Vector2 = target_position - current_position
	var distance: float = direction.length()

	if distance <= max_distance or distance <= 0.0:
		return target_position

	return current_position + direction.normalized() * max_distance

func _resolve_slime_combat(traveler: Dictionary, slime_id: int = -1, encounter_source: String = "") -> void:
	var starting_hp: int = int(traveler.get("hp", 30))
	var adventurer_hp: int = starting_hp
	var adventurer_max_hp: int = int(traveler.get("max_hp", 30))
	var adventurer_attack: int = int(traveler.get("attack", 7))
	var adventurer_speed: float = float(traveler.get("speed", 1.0))
	var adventurer_meter: float = 0.0

	var slime_starting_hp: int = get_current_slime_max_hp()
	var slime_hp: int = slime_starting_hp
	var slime_attack: int = get_current_slime_attack()
	var slime_meter: float = 0.0
	var night_combat: bool = _is_night()

	if night_combat:
		slime_hp = ceili(float(get_current_slime_max_hp()) * NIGHT_SLIME_HP_MULTIPLIER)
		slime_starting_hp = slime_hp
		slime_attack = ceili(float(get_current_slime_attack()) * NIGHT_SLIME_ATTACK_MULTIPLIER)
		traveler["last_combat_log"] = "Night combat: Slime empowered."

	var inventory: Dictionary = traveler.get("inventory", {})
	var slime_gel_reward: int = get_current_slime_gel_reward()
	var potion_used: bool = false

	var rounds: int = 0
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

	var damage_taken: int = maxi(starting_hp - adventurer_hp, 0)
	var damage_dealt: int = maxi(slime_starting_hp - maxi(slime_hp, 0), 0)

	traveler["hp"] = maxi(adventurer_hp, 0)
	traveler["inventory"] = inventory
	traveler["target_slime_id"] = -1
	traveler["combat_contact_timer"] = 0.0
	traveler["combat_cooldown_timer"] = COMBAT_REENGAGE_COOLDOWN
	traveler["last_damage_taken"] = damage_taken
	traveler["last_damage_dealt"] = damage_dealt

	var night_note: String = ""
	if night_combat:
		night_note = " Night danger applied."

	var source_note: String = ""
	if encounter_source == "ambush":
		source_note = " Ambushed by visible Slime."
	elif encounter_source == "targeted":
		source_note = " Defeated visible Slime."

	if slime_hp <= 0:
		inventory[SLIME_GEL_ID] = int(inventory.get(SLIME_GEL_ID, 0)) + slime_gel_reward
		traveler["inventory"] = inventory
		traveler["slime_kills_this_outing"] = int(traveler.get("slime_kills_this_outing", 0)) + 1
		_mark_slime_defeated(slime_id)

		if _should_traveler_return_after_victory(traveler):
			if _is_traveler_weakened_for_retreat_danger(traveler):
				traveler["status"] = "FleeingToTown"
				traveler["flee_grace_timer"] = FLEE_GRACE_SECONDS
				traveler["target_position"] = TOWN_WORLD_POSITION
				traveler["last_combat_log"] = "Won vs Slime. +%d Gel. Low HP, fleeing. Kills %d/%d.%s%s" % [
					slime_gel_reward,
					int(traveler.get("slime_kills_this_outing", 0)),
					MAX_SLIME_KILLS_PER_OUTING,
					night_note,
					source_note
				]
			else:
				traveler["status"] = "ReturningWithLoot"
				traveler["target_position"] = TOWN_WORLD_POSITION
				traveler["last_combat_log"] = "Won vs Slime. +%d Gel. Returning. Kills %d/%d.%s%s" % [
					slime_gel_reward,
					int(traveler.get("slime_kills_this_outing", 0)),
					MAX_SLIME_KILLS_PER_OUTING,
					night_note,
					source_note
				]
		else:
			traveler["status"] = "SeekingNextSlime"
			traveler["target_position"] = SLIME_NEST_WORLD_POSITION
			traveler["last_combat_log"] = "Won vs Slime. +%d Gel. Hunting next. Kills %d/%d.%s%s" % [
				slime_gel_reward,
				int(traveler.get("slime_kills_this_outing", 0)),
				MAX_SLIME_KILLS_PER_OUTING,
				night_note,
				source_note
			]

		if str(traveler.get("status", "")) == "FleeingToTown":
			traveler["floating_event_text"] = "Flee!"
		elif str(traveler.get("status", "")) == "ReturningWithLoot":
			traveler["floating_event_text"] = "Return!"
		else:
			traveler["floating_event_text"] = "Victory!"

	elif adventurer_hp <= 0:
		traveler["status"] = "InjuredReturning"
		traveler["target_position"] = TOWN_WORLD_POSITION
		traveler["flee_grace_timer"] = FLEE_GRACE_SECONDS
		traveler["last_combat_log"] = "Lost vs Slime. Returning injured.%s%s" % [night_note, source_note]
		traveler["floating_event_text"] = "Defeated!"
		_release_slime_after_combat(slime_id)
	else:
		traveler["status"] = "InjuredReturning"
		traveler["target_position"] = TOWN_WORLD_POSITION
		traveler["flee_grace_timer"] = FLEE_GRACE_SECONDS
		traveler["last_combat_log"] = "Combat timed out. Retreating.%s%s" % [night_note, source_note]
		traveler["floating_event_text"] = "Retreat!"
		_release_slime_after_combat(slime_id)

	if potion_used:
		traveler["last_combat_log"] += " Potion used."

func _should_traveler_return_after_victory(traveler: Dictionary) -> bool:
	var hp: int = int(traveler.get("hp", 0))
	var max_hp: int = int(traveler.get("max_hp", 30))
	if hp <= _get_retreat_hp_threshold(max_hp):
		traveler["last_combat_log"] = "Health low. Returning."
		return true

	if int(traveler.get("slime_kills_this_outing", 0)) >= MAX_SLIME_KILLS_PER_OUTING:
		return true

	return false

func _mark_slime_defeated(slime_id: int) -> void:
	if slime_id < 0:
		return

	for index in range(world_slimes.size()):
		if int(world_slimes[index].get("id", -1)) == slime_id:
			var slime: Dictionary = world_slimes[index]
			slime["status"] = "Defeated"
			slime["target_traveler_id"] = -1
			slime["defeat_timer"] = SLIME_DEFEAT_DISPLAY_SECONDS
			slime["is_active"] = true
			slime["last_event_log"] = "Slime defeated."
			world_slimes[index] = slime
			return

func _release_slime_after_combat(slime_id: int) -> void:
	if slime_id < 0:
		return

	for index in range(world_slimes.size()):
		if int(world_slimes[index].get("id", -1)) == slime_id:
			var slime: Dictionary = world_slimes[index]
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


func save_world_state_to_file(show_warning: bool = true) -> bool:
	var save_manager: Node = get_node_or_null("/root/SaveManager")

	if save_manager == null or not save_manager.has_method("save_world_state_data"):
		if show_warning:
			push_warning("Failed to save world state. SaveManager unavailable.")
		return false

	return bool(save_manager.save_world_state_data(get_world_state_save_data(), show_warning))

func load_world_state_from_file(show_warning: bool = true) -> bool:
	var save_manager: Node = get_node_or_null("/root/SaveManager")

	if save_manager == null or not save_manager.has_method("load_world_state_data"):
		if show_warning:
			push_warning("Failed to load world state. SaveManager unavailable.")
		return false

	var save_data: Dictionary = save_manager.load_world_state_data(show_warning)
	if save_data.is_empty():
		return false

	return apply_world_state_save_data(save_data, show_warning)

func get_world_state_save_data() -> Dictionary:
	return {
		"version": WORLD_STATE_SAVE_VERSION,
		"next_world_traveler_id": next_world_traveler_id,
		"next_world_slime_id": next_world_slime_id,
		"slime_nest_status": slime_nest_status,
		"slime_nest_growth": slime_nest_growth,
		"slime_nest_level": get_slime_nest_level(),
		"raid_pressure_state": get_raid_pressure_state(),
		"slime_spawn_timer": _slime_spawn_timer,
		"active_world_travelers": _serialize_world_dictionary_array(world_travelers),
		"returned_traveler_records": _serialize_world_dictionary_array(returned_travelers),
		"visible_slime_state": _serialize_world_dictionary_array(world_slimes),
		"summary": {
			"active_world_traveler_count": world_travelers.size(),
			"returned_traveler_record_count": returned_travelers.size(),
			"visible_slime_count": get_world_slime_count(),
			"slime_nest_status": slime_nest_status,
			"slime_nest_growth": slime_nest_growth,
			"slime_nest_level": get_slime_nest_level()
		}
	}

func apply_world_state_save_data(save_data: Dictionary, show_warning: bool = true) -> bool:
	if save_data.is_empty():
		if show_warning:
			push_warning("World state save data is empty.")
		return false

	next_world_traveler_id = maxi(1, int(save_data.get("next_world_traveler_id", next_world_traveler_id)))
	next_world_slime_id = maxi(1, int(save_data.get("next_world_slime_id", next_world_slime_id)))
	slime_nest_status = str(save_data.get("slime_nest_status", "Dormant"))
	slime_nest_growth = maxi(0, int(save_data.get("slime_nest_growth", 0)))
	_slime_spawn_timer = float(save_data.get("slime_spawn_timer", _slime_spawn_timer))

	world_travelers = _deserialize_world_dictionary_array(save_data.get("active_world_travelers", []), "traveler")
	returned_travelers = _deserialize_world_dictionary_array(save_data.get("returned_traveler_records", []), "returned_traveler")
	world_slimes = _deserialize_world_dictionary_array(save_data.get("visible_slime_state", []), "slime")

	state_changed.emit()
	return true

func get_world_state_status_text() -> String:
	return "World travelers: %d\nReturned records: %d\nVisible slimes: %d\nNest: %s L%d Growth:%d Raid:%s" % [
		world_travelers.size(),
		returned_travelers.size(),
		get_world_slime_count(),
		slime_nest_status,
		get_slime_nest_level(),
		slime_nest_growth,
		get_raid_pressure_state()
	]

func _serialize_world_dictionary_array(source_array: Array[Dictionary]) -> Array[Dictionary]:
	var output: Array[Dictionary] = []

	for source_item in source_array:
		var item: Dictionary = source_item.duplicate(true)
		_pack_vector2_field(item, "world_position")
		_pack_vector2_field(item, "target_position")
		_pack_vector2_field(item, "wander_target_position")
		output.append(item)

	return output

func _deserialize_world_dictionary_array(raw_array: Variant, kind: String) -> Array[Dictionary]:
	var output: Array[Dictionary] = []

	if not raw_array is Array:
		return output

	var source_array: Array = raw_array as Array
	for raw_item in source_array:
		if not raw_item is Dictionary:
			continue

		var item: Dictionary = (raw_item as Dictionary).duplicate(true)
		_unpack_vector2_field(item, "world_position", TOWN_WORLD_POSITION if kind != "slime" else SLIME_NEST_WORLD_POSITION)
		_unpack_vector2_field(item, "target_position", SLIME_NEST_WORLD_POSITION if kind == "traveler" else TOWN_WORLD_POSITION)
		_unpack_vector2_field(item, "wander_target_position", _get_random_slime_wander_position())
		output.append(item)

	return output

func _pack_vector2_field(item: Dictionary, field_name: String) -> void:
	if not item.has(field_name):
		return

	var raw_value: Variant = item.get(field_name)
	if raw_value is Vector2:
		var vector_value: Vector2 = raw_value as Vector2
		item[field_name] = {
			"x": vector_value.x,
			"y": vector_value.y
		}

func _unpack_vector2_field(item: Dictionary, field_name: String, fallback: Vector2) -> void:
	if not item.has(field_name):
		item[field_name] = fallback
		return

	var raw_value: Variant = item.get(field_name)
	if raw_value is Dictionary:
		var raw_dict: Dictionary = raw_value as Dictionary
		item[field_name] = Vector2(
			float(raw_dict.get("x", fallback.x)),
			float(raw_dict.get("y", fallback.y))
		)
	elif raw_value is Vector2:
		item[field_name] = raw_value
	else:
		item[field_name] = fallback

func grow_slime_nest(amount: int = 1) -> void:
	slime_nest_growth += amount

	if slime_nest_growth <= 0:
		slime_nest_growth = 0
		slime_nest_status = "Dormant"
	elif slime_nest_growth < 3:
		slime_nest_status = "Growing"
	elif slime_nest_growth < 6:
		slime_nest_status = "Dangerous"
	elif slime_nest_growth < 9:
		slime_nest_status = "Raid Risk"
	else:
		slime_nest_status = "Critical"

	state_changed.emit()
