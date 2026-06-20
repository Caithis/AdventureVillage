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

const DEFAULT_REGIONAL_ADVENTURER_CAP := 3
const VISITOR_MIN_VISIT_DAYS := 3
const VISITOR_MAX_VISIT_DAYS := 5
const VISITOR_EVENT_LOG_LIMIT := 12

const QUEST_TYPE_HUNT_SLIMES := "hunt_slimes"
const QUEST_STATUS_ACTIVE := "active"
const QUEST_STATUS_COMPLETED := "completed"
const DEFAULT_SLIME_HUNT_TARGET := 3
const DEFAULT_SLIME_HUNT_REWARD_GOLD := 60
const DISCOVERY_EVENT_LOG_LIMIT := 12
const QUEST_ENCOURAGEMENT_COST_GOLD := 35
const QUEST_ENCOURAGEMENT_DURATION_DAYS := 1
const QUEST_ENCOURAGED_SPEED_MULTIPLIER := 1.25
const QUEST_ENCOURAGED_COOLDOWN_MULTIPLIER := 0.70
const VISITOR_POOL_TEMPLATE_NAMES: Array[String] = [
    "Rook",
    "Mira",
    "Bram",
    "Tessa",
    "Galen",
    "Nia",
    "Orin",
    "Lysa",
    "Perrin",
    "Sable",
    "Doran",
    "Ilyra",
    "Kest",
    "Marn",
    "Vela"
]

var money: int = 500
var simulation_paused: bool = false

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
var economy_quest_reward_injection: int = 0
var economy_quest_reward_count: int = 0
var economy_quest_encouragement_outflow: int = 0
var economy_quest_encouragement_count: int = 0
var economy_quest_reward_spent_in_town: int = 0
var economy_quest_reward_spent_count: int = 0
var economy_quest_reward_spent_general_store: int = 0
var economy_quest_reward_spent_inn: int = 0
var economy_quest_reward_last_spend_message: String = "No quest reward spending recorded yet."

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

var active_regional_adventurer_cap: int = DEFAULT_REGIONAL_ADVENTURER_CAP
var visitor_intake_enabled: bool = true
var visitor_pool: Array[Dictionary] = []
var departed_visitor_history: Array[Dictionary] = []
var visitor_event_log: Array[Dictionary] = []
var next_visitor_id: int = 1

var known_monsters: Dictionary = {}
var known_nests: Dictionary = {}
var discovery_event_log: Array[Dictionary] = []

var active_quest: Dictionary = {}
var completed_quest_log: Array[Dictionary] = []
var quest_event_log: Array[Dictionary] = []
var next_quest_id: int = 1

var next_world_traveler_id: int = 1
var next_world_slime_id: int = 1

var slime_nest_status: String = "Dormant"
var slime_nest_growth: int = 0

var _world_simulation_emit_timer: float = 0.0
var _world_simulation_emit_interval: float = 0.15
var _slime_spawn_timer: float = 999.0

func _process(delta: float) -> void:
    if has_method("is_simulation_paused") and is_simulation_paused():
        return

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

func record_quest_encouragement_outflow(amount: int, reason: String = "quest_encouragement") -> void:
    if amount <= 0:
        return

    economy_quest_encouragement_outflow += amount
    economy_quest_encouragement_count += 1
    _add_to_current_day_bucket("quest_encouragement_outflow", amount)
    _add_to_current_day_bucket("quest_encouragement_count", 1)
    save_economy_history_to_file(false)
    state_changed.emit()

func get_quest_encouragement_economy_status_text() -> String:
    return "Quest Encouragement Cost: %dg across %d use(s)" % [
        economy_quest_encouragement_outflow,
        economy_quest_encouragement_count
    ]

func record_quest_reward_spent_in_town(amount: int, service_id: String = "unknown", adventurer_name: String = "Adventurer") -> void:
    if amount <= 0:
        return

    economy_quest_reward_spent_in_town += amount
    economy_quest_reward_spent_count += 1

    var normalized_service: String = service_id.to_lower()
    if normalized_service.contains("inn") or normalized_service.contains("lodging") or normalized_service.contains("rest"):
        economy_quest_reward_spent_inn += amount
        _add_to_current_day_bucket("quest_reward_spent_inn", amount)
    elif normalized_service.contains("store") or normalized_service.contains("potion"):
        economy_quest_reward_spent_general_store += amount
        _add_to_current_day_bucket("quest_reward_spent_general_store", amount)

    _add_to_current_day_bucket("quest_reward_spent_in_town", amount)
    _add_to_current_day_bucket("quest_reward_spent_count", 1)

    economy_quest_reward_last_spend_message = "%s spent %dg quest reward money at %s." % [
        adventurer_name,
        amount,
        service_id
    ]

    log_quest_event("reward_spent", economy_quest_reward_last_spend_message, adventurer_name)
    save_economy_history_to_file(false)
    state_changed.emit()

func get_quest_reward_spending_loop_status_text() -> String:
    return "Quest Reward Spending Loop: %dg spent back into town across %d purchase(s) | Store:%dg | Inn:%dg | Last:%s" % [
        economy_quest_reward_spent_in_town,
        economy_quest_reward_spent_count,
        economy_quest_reward_spent_general_store,
        economy_quest_reward_spent_inn,
        economy_quest_reward_last_spend_message
    ]

func get_adventurer_quest_reward_wallet_status_text() -> String:
    var parts: Array[String] = []

    for traveler in world_travelers:
        var q_gold: int = int(traveler.get("quest_reward_gold", 0))
        if q_gold > 0:
            parts.append("%s World Gold:%dg QuestGold:%dg" % [
                str(traveler.get("display_name", "Traveler")),
                int(traveler.get("gold", 0)),
                q_gold
            ])

    for traveler in returned_travelers:
        var q_gold: int = int(traveler.get("quest_reward_gold", 0))
        if q_gold > 0:
            parts.append("%s Returned Gold:%dg QuestGold:%dg" % [
                str(traveler.get("display_name", "Traveler")),
                int(traveler.get("gold", 0)),
                q_gold
            ])

    for adventurer in adventurers:
        if adventurer == null or not is_instance_valid(adventurer):
            continue

        var q_gold: int = int(_safe_get_property(adventurer, "quest_reward_gold", 0))
        if q_gold > 0:
            parts.append("%s Town Gold:%dg QuestGold:%dg" % [
                str(_safe_get_property(adventurer, "display_name", "Adventurer")),
                int(_safe_get_property(adventurer, "gold", 0)),
                q_gold
            ])

    for visitor in visitor_pool:
        var q_gold: int = int(visitor.get("quest_reward_gold", 0))
        if q_gold > 0:
            parts.append("%s Pool Gold:%dg QuestGold:%dg" % [
                str(visitor.get("display_name", "Visitor")),
                int(visitor.get("gold", 0)),
                q_gold
            ])

    if parts.is_empty():
        return "Adventurer Quest Reward Wallets: none currently tracked."

    return "Adventurer Quest Reward Wallets:\n%s" % "\n".join(parts.slice(0, 6))

func record_quest_reward_injection(amount: int, recipient_name: String = "Adventurer") -> void:
    if amount <= 0:
        return

    economy_quest_reward_injection += amount
    economy_quest_reward_count += 1
    _add_to_current_day_bucket("quest_reward_injection", amount)
    _add_to_current_day_bucket("quest_reward_count", 1)
    save_economy_history_to_file(false)
    state_changed.emit()

func get_quest_reward_economy_status_text() -> String:
    return "Quest Reward Injection: %dg across %d payment(s)" % [
        economy_quest_reward_injection,
        economy_quest_reward_count
    ]

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
        "quest_reward_injection": 0,
        "quest_reward_count": 0,
        "quest_encouragement_outflow": 0,
        "quest_encouragement_count": 0,
        "quest_reward_spent_in_town": 0,
        "quest_reward_spent_count": 0,
        "quest_reward_spent_general_store": 0,
        "quest_reward_spent_inn": 0,
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
    economy_quest_reward_injection = 0
    economy_quest_reward_count = 0
    economy_quest_encouragement_outflow = 0
    economy_quest_encouragement_count = 0
    economy_quest_reward_spent_in_town = 0
    economy_quest_reward_spent_count = 0
    economy_quest_reward_spent_general_store = 0
    economy_quest_reward_spent_inn = 0
    economy_quest_reward_last_spend_message = "No quest reward spending recorded yet."
    economy_daily_buckets.clear()
    ensure_economy_bucket_for_day(get_current_economy_day_number())
    save_economy_history_to_file(false)
    state_changed.emit()




func set_simulation_paused(is_paused: bool) -> void:
    if simulation_paused == is_paused:
        return

    simulation_paused = is_paused
    state_changed.emit()

func is_simulation_paused() -> bool:
    return simulation_paused

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
        "general_store_buys_slime_gel": general_store_buys_slime_gel,
        "visitor_pool": visitor_pool.duplicate(true),
        "departed_visitor_history": departed_visitor_history.duplicate(true),
        "visitor_event_log": visitor_event_log.duplicate(true),
        "next_visitor_id": next_visitor_id,
        "active_regional_adventurer_cap": active_regional_adventurer_cap,
        "visitor_intake_enabled": visitor_intake_enabled,
        "known_monsters": known_monsters.duplicate(true),
        "known_nests": known_nests.duplicate(true),
        "discovery_event_log": discovery_event_log.duplicate(true),
        "active_quest": active_quest.duplicate(true),
        "completed_quest_log": completed_quest_log.duplicate(true),
        "quest_event_log": quest_event_log.duplicate(true),
        "next_quest_id": next_quest_id
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

    var raw_visitor_pool: Variant = save_data.get("visitor_pool", [])
    if raw_visitor_pool is Array:
        visitor_pool = []
        for raw_visitor in raw_visitor_pool as Array:
            if raw_visitor is Dictionary:
                visitor_pool.append((raw_visitor as Dictionary).duplicate(true))

    var raw_departed_history: Variant = save_data.get("departed_visitor_history", [])
    if raw_departed_history is Array:
        departed_visitor_history = []
        for raw_departed in raw_departed_history as Array:
            if raw_departed is Dictionary:
                departed_visitor_history.append((raw_departed as Dictionary).duplicate(true))

    var raw_visitor_event_log: Variant = save_data.get("visitor_event_log", [])
    if raw_visitor_event_log is Array:
        visitor_event_log = []
        for raw_event in raw_visitor_event_log as Array:
            if raw_event is Dictionary:
                visitor_event_log.append((raw_event as Dictionary).duplicate(true))

    next_visitor_id = maxi(1, int(save_data.get("next_visitor_id", next_visitor_id)))
    active_regional_adventurer_cap = maxi(1, int(save_data.get("active_regional_adventurer_cap", active_regional_adventurer_cap)))
    visitor_intake_enabled = bool(save_data.get("visitor_intake_enabled", visitor_intake_enabled))

    var raw_known_monsters: Variant = save_data.get("known_monsters", {})
    if raw_known_monsters is Dictionary:
        known_monsters = (raw_known_monsters as Dictionary).duplicate(true)

    var raw_known_nests: Variant = save_data.get("known_nests", {})
    if raw_known_nests is Dictionary:
        known_nests = (raw_known_nests as Dictionary).duplicate(true)

    var raw_discovery_event_log: Variant = save_data.get("discovery_event_log", [])
    if raw_discovery_event_log is Array:
        discovery_event_log = []
        for raw_event in raw_discovery_event_log as Array:
            if raw_event is Dictionary:
                discovery_event_log.append((raw_event as Dictionary).duplicate(true))

    var raw_active_quest: Variant = save_data.get("active_quest", {})
    if raw_active_quest is Dictionary:
        active_quest = (raw_active_quest as Dictionary).duplicate(true)

    var raw_completed_quest_log: Variant = save_data.get("completed_quest_log", [])
    if raw_completed_quest_log is Array:
        completed_quest_log = []
        for raw_quest in raw_completed_quest_log as Array:
            if raw_quest is Dictionary:
                completed_quest_log.append((raw_quest as Dictionary).duplicate(true))

    var raw_quest_event_log: Variant = save_data.get("quest_event_log", [])
    if raw_quest_event_log is Array:
        quest_event_log = []
        for raw_event in raw_quest_event_log as Array:
            if raw_event is Dictionary:
                quest_event_log.append((raw_event as Dictionary).duplicate(true))

    next_quest_id = maxi(1, int(save_data.get("next_quest_id", next_quest_id)))

    state_changed.emit()
    return true

func get_core_state_status_text() -> String:
    return "Gold: %dg\nPotions: %d\nSlime Gel: %d\nNight Quests: %s\nStore Buying Slime Gel: %s\n%s" % [
        money,
        get_item_count(SMALL_POTION_ID),
        get_item_count(SLIME_GEL_ID),
        get_night_quest_policy_text(),
        "Yes" if general_store_buys_slime_gel else "No",
        get_visitor_population_status_text()
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
            "quest_reward_injection": economy_quest_reward_injection,
            "quest_reward_count": economy_quest_reward_count,
            "quest_encouragement_outflow": economy_quest_encouragement_outflow,
            "quest_encouragement_count": economy_quest_encouragement_count,
            "quest_reward_spent_in_town": economy_quest_reward_spent_in_town,
            "quest_reward_spent_count": economy_quest_reward_spent_count,
            "quest_reward_spent_general_store": economy_quest_reward_spent_general_store,
            "quest_reward_spent_inn": economy_quest_reward_spent_inn,
            "quest_reward_last_spend_message": economy_quest_reward_last_spend_message,
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
    economy_quest_reward_injection = int(totals.get("quest_reward_injection", 0))
    economy_quest_reward_count = int(totals.get("quest_reward_count", 0))
    economy_quest_encouragement_outflow = int(totals.get("quest_encouragement_outflow", 0))
    economy_quest_encouragement_count = int(totals.get("quest_encouragement_count", 0))
    economy_quest_reward_spent_in_town = int(totals.get("quest_reward_spent_in_town", 0))
    economy_quest_reward_spent_count = int(totals.get("quest_reward_spent_count", 0))
    economy_quest_reward_spent_general_store = int(totals.get("quest_reward_spent_general_store", 0))
    economy_quest_reward_spent_inn = int(totals.get("quest_reward_spent_inn", 0))
    economy_quest_reward_last_spend_message = str(totals.get("quest_reward_last_spend_message", economy_quest_reward_last_spend_message))

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


func get_active_regional_adventurer_count() -> int:
    return get_adventurer_count() + get_world_traveler_count()

func get_regional_adventurer_cap() -> int:
    return active_regional_adventurer_cap

func set_regional_adventurer_cap(new_cap: int) -> void:
    var safe_cap: int = maxi(1, new_cap)
    if active_regional_adventurer_cap == safe_cap:
        return

    active_regional_adventurer_cap = safe_cap
    state_changed.emit()

func get_regional_adventurer_open_slots() -> int:
    return maxi(get_regional_adventurer_cap() - get_active_regional_adventurer_count(), 0)

func get_guild_hall_cap_bonus_placeholder() -> int:
    return maxi(get_regional_adventurer_cap() - DEFAULT_REGIONAL_ADVENTURER_CAP, 0)

func is_visitor_intake_enabled() -> bool:
    return visitor_intake_enabled

func set_visitor_intake_enabled(enabled: bool) -> void:
    if visitor_intake_enabled == enabled:
        return

    visitor_intake_enabled = enabled
    state_changed.emit()

func toggle_visitor_intake() -> bool:
    set_visitor_intake_enabled(not visitor_intake_enabled)
    return visitor_intake_enabled

func get_visitor_intake_policy_text() -> String:
    return "Accepting Visitors" if visitor_intake_enabled else "Visitor Intake Closed"

func get_visitor_cap_warning_text() -> String:
    if not visitor_intake_enabled:
        return "Visitor intake is closed."

    if get_active_regional_adventurer_count() >= get_regional_adventurer_cap():
        return "Regional adventurer cap is full."

    return "%d regional visitor slot(s) open." % get_regional_adventurer_open_slots()

func can_spawn_regional_visitor() -> bool:
    return visitor_intake_enabled and get_active_regional_adventurer_count() < get_regional_adventurer_cap()

func get_available_visitor_pool_count() -> int:
    var count: int = 0
    for visitor in visitor_pool:
        if str(visitor.get("status", "available")) == "available":
            count += 1
    return count

func get_active_visitor_pool_count() -> int:
    var count: int = 0
    for visitor in visitor_pool:
        if str(visitor.get("status", "")) == "active":
            count += 1
    return count

func get_visitor_population_status_text() -> String:
    return "Intake: %s | Active: %d/%d | Open: %d | Pool Available: %d | Pool Total: %d | Departed: %d | Guild Bonus: +%d | Two-trip: temporary | %s" % [
        get_visitor_intake_policy_text(),
        get_active_regional_adventurer_count(),
        get_regional_adventurer_cap(),
        get_regional_adventurer_open_slots(),
        get_available_visitor_pool_count(),
        visitor_pool.size(),
        departed_visitor_history.size(),
        get_guild_hall_cap_bonus_placeholder(),
        get_visitor_cap_warning_text()
    ]


func log_visitor_event(event_type: String, visitor_name: String, reason: String = "") -> void:
    var event := {
        "day": _get_current_day_number_for_visitors(),
        "event_type": event_type,
        "visitor_name": visitor_name,
        "reason": reason
    }

    visitor_event_log.append(event)

    while visitor_event_log.size() > VISITOR_EVENT_LOG_LIMIT:
        visitor_event_log.remove_at(0)

    state_changed.emit()

func get_visitor_event_log_text(max_events: int = 5) -> String:
    if visitor_event_log.is_empty():
        return "Visitor Log: No visitor events recorded yet."

    var lines: Array[String] = []
    var start_index: int = maxi(visitor_event_log.size() - max_events, 0)

    for index in range(start_index, visitor_event_log.size()):
        var event: Dictionary = visitor_event_log[index]
        var reason_text: String = str(event.get("reason", ""))
        if reason_text != "":
            reason_text = " | %s" % reason_text

        lines.append("Day %d: %s - %s%s" % [
            int(event.get("day", 1)),
            str(event.get("event_type", "event")),
            str(event.get("visitor_name", "Visitor")),
            reason_text
        ])

    return "Visitor Log:\\n%s" % "\\n".join(lines)

func get_visitor_compact_status_text() -> String:
    return "Visitors %d/%d | Open %d | Pool %d/%d | Known %d | Fav %d | Intake %s" % [
        get_active_regional_adventurer_count(),
        get_regional_adventurer_cap(),
        get_regional_adventurer_open_slots(),
        get_available_visitor_pool_count(),
        visitor_pool.size(),
        get_known_adventurer_count(),
        get_favorite_known_adventurer_count(),
        "Open" if visitor_intake_enabled else "Closed"
    ]

func get_last_departure_reason_text() -> String:
    if departed_visitor_history.is_empty():
        return "No departures recorded yet."

    var latest: Dictionary = departed_visitor_history[departed_visitor_history.size() - 1]
    return "Last Departure: %s | Day %d | %s" % [
        str(latest.get("display_name", "Visitor")),
        int(latest.get("departure_day", 1)),
        str(latest.get("reason", "unknown"))
    ]






func log_discovery_event(event_type: String, message: String, source: String = "") -> void:
    var event := {
        "day": _get_current_day_number_for_visitors(),
        "event_type": event_type,
        "message": message,
        "source": source
    }

    discovery_event_log.append(event)

    while discovery_event_log.size() > DISCOVERY_EVENT_LOG_LIMIT:
        discovery_event_log.remove_at(0)

func discover_monster_type(monster_id: String, display_name: String, source: String = "sighting") -> bool:
    if monster_id == "":
        return false

    var was_new: bool = not known_monsters.has(monster_id)
    var monster: Dictionary = known_monsters.get(monster_id, {})
    var current_day: int = _get_current_day_number_for_visitors()

    monster["monster_id"] = monster_id
    monster["display_name"] = display_name
    monster["status"] = "discovered"
    monster["last_seen_day"] = current_day
    monster["last_source"] = source
    monster["sightings"] = int(monster.get("sightings", 0)) + 1

    if was_new:
        monster["first_seen_day"] = current_day
        log_discovery_event("monster_discovered", "Discovered monster: %s." % display_name, source)
    elif source == "slime_defeated":
        log_discovery_event("monster_confirmed", "Confirmed %s through combat." % display_name, source)

    known_monsters[monster_id] = monster
    state_changed.emit()
    return was_new

func discover_nest(nest_id: String, display_name: String, monster_id: String, source: String = "sighting") -> bool:
    if nest_id == "":
        return false

    var was_new: bool = not known_nests.has(nest_id)
    var nest: Dictionary = known_nests.get(nest_id, {})
    var current_day: int = _get_current_day_number_for_visitors()

    nest["nest_id"] = nest_id
    nest["display_name"] = display_name
    nest["monster_id"] = monster_id
    nest["status"] = "known"
    nest["last_seen_day"] = current_day
    nest["last_source"] = source
    nest["nest_level"] = get_slime_nest_level() if nest_id == "slime_nest" else int(nest.get("nest_level", 1))
    nest["growth"] = slime_nest_growth if nest_id == "slime_nest" else int(nest.get("growth", 0))
    nest["active_monsters"] = get_world_slime_count() if nest_id == "slime_nest" else int(nest.get("active_monsters", 0))

    if was_new:
        nest["first_seen_day"] = current_day
        log_discovery_event("nest_discovered", "Discovered nest: %s." % display_name, source)

    known_nests[nest_id] = nest
    state_changed.emit()
    return was_new

func discover_slime_threats(source: String = "sighting") -> void:
    discover_monster_type("slime", "Slime", source)
    discover_nest("slime_nest", "Slime Nest", "slime", source)

func _sync_known_slime_nest_status() -> void:
    if not known_nests.has("slime_nest"):
        return

    var nest: Dictionary = known_nests.get("slime_nest", {})
    nest["nest_level"] = get_slime_nest_level()
    nest["growth"] = slime_nest_growth
    nest["active_monsters"] = get_world_slime_count()
    nest["raid_pressure"] = get_raid_pressure_score()
    nest["raid_state"] = get_raid_pressure_state()
    known_nests["slime_nest"] = nest

func debug_discover_known_threats() -> String:
    discover_slime_threats("debug_discover")
    state_changed.emit()
    return "Known threats updated: Slime and Slime Nest discovered."

func debug_reset_known_threats() -> String:
    known_monsters.clear()
    known_nests.clear()
    discovery_event_log.clear()
    state_changed.emit()
    return "Known threat discovery data reset."

func get_known_monster_list_text() -> String:
    if known_monsters.is_empty():
        return "Known Monsters: None"

    var parts: Array[String] = []
    for monster_id in known_monsters.keys():
        var monster: Dictionary = known_monsters[monster_id]
        parts.append("%s sightings:%d last:%s" % [
            str(monster.get("display_name", monster_id)),
            int(monster.get("sightings", 0)),
            str(monster.get("last_source", "unknown"))
        ])

    return "Known Monsters: %s" % ", ".join(parts)

func get_known_nest_status_text() -> String:
    _sync_known_slime_nest_status()

    if known_nests.is_empty():
        return "Known Nests: None"

    var lines: Array[String] = []
    for nest_id in known_nests.keys():
        var nest: Dictionary = known_nests[nest_id]
        lines.append("%s | Monster:%s | Level:%d | Growth:%d | Active:%d | Raid:%s" % [
            str(nest.get("display_name", nest_id)),
            str(nest.get("monster_id", "unknown")),
            int(nest.get("nest_level", 1)),
            int(nest.get("growth", 0)),
            int(nest.get("active_monsters", 0)),
            str(nest.get("raid_state", "Unknown"))
        ])

    return "Known Nests:\n%s" % "\n".join(lines)

func get_discovery_event_log_text(max_events: int = 5) -> String:
    if discovery_event_log.is_empty():
        return "Discovery Events: None"

    var lines: Array[String] = []
    var start_index: int = maxi(discovery_event_log.size() - max_events, 0)

    for index in range(start_index, discovery_event_log.size()):
        var event: Dictionary = discovery_event_log[index]
        lines.append("Day %d: %s | %s" % [
            int(event.get("day", 1)),
            str(event.get("event_type", "event")),
            str(event.get("message", ""))
        ])

    return "Discovery Events:\n%s" % "\n".join(lines)

func get_known_threats_status_text() -> String:
    return "WORLD DISCOVERY / KNOWN THREATS PLACEHOLDER\n%s\n%s\n%s\n\nQuest Builder Note: future Hunt dropdowns should only use discovered monsters and known nests." % [
        get_known_monster_list_text(),
        get_known_nest_status_text(),
        get_discovery_event_log_text(4)
    ]

func log_quest_event(event_type: String, message: String, contributor_name: String = "") -> void:
    var event := {
        "day": _get_current_day_number_for_visitors(),
        "event_type": event_type,
        "message": message,
        "contributor_name": contributor_name
    }

    quest_event_log.append(event)

    while quest_event_log.size() > 12:
        quest_event_log.remove_at(0)

func get_quest_event_log_text(max_events: int = 5) -> String:
    if quest_event_log.is_empty():
        return "Quest Events: None"

    var lines: Array[String] = []
    var start_index: int = maxi(quest_event_log.size() - max_events, 0)

    for index in range(start_index, quest_event_log.size()):
        var event: Dictionary = quest_event_log[index]
        lines.append("Day %d: %s | %s" % [
            int(event.get("day", 1)),
            str(event.get("event_type", "event")),
            str(event.get("message", ""))
        ])

    return "Quest Events:\\n%s" % "\\n".join(lines)

func get_last_quest_feedback_text() -> String:
    if quest_event_log.is_empty():
        return "Last Quest Feedback: None"

    var latest: Dictionary = quest_event_log[quest_event_log.size() - 1]
    return "Last Quest Feedback: %s" % str(latest.get("message", ""))

func has_active_quest() -> bool:
    return not active_quest.is_empty() and str(active_quest.get("status", "")) == QUEST_STATUS_ACTIVE

func debug_create_slime_hunt_quest(target_count: int = DEFAULT_SLIME_HUNT_TARGET) -> String:
    if has_active_quest():
        return "Quest already active: %s" % str(active_quest.get("title", "Active Quest"))

    var safe_target: int = maxi(1, target_count)
    active_quest = {
        "id": next_quest_id,
        "title": "Cull the Slimes",
        "quest_type": QUEST_TYPE_HUNT_SLIMES,
        "status": QUEST_STATUS_ACTIVE,
        "target_id": "slime",
        "target_count": safe_target,
        "progress_count": 0,
        "reward_gold": DEFAULT_SLIME_HUNT_REWARD_GOLD,
        "reward_source": "external_commission_placeholder",
        "reward_paid_to_adventurers": false,
        "reward_distribution": {},
        "contributor_kills": {},
        "encouragement_active": false,
        "encouragement_until_day": 0,
        "encouragement_cost_gold": QUEST_ENCOURAGEMENT_COST_GOLD,
        "encouragement_total_spent": 0,
        "encouragement_count": 0,
        "progress_events": [],
        "created_day": _get_current_day_number_for_visitors(),
        "completed_day": 0,
        "last_event": "Quest posted at Guild Hall.",
        "last_feedback": "Quest posted: Cull Slimes.",
        "source": "debug_quest_board_placeholder"
    }
    next_quest_id += 1
    var message: String = "Quest posted: Cull %d Slimes." % safe_target
    log_quest_event("posted", message, "")
    state_changed.emit()
    return message

func clear_active_quest_debug() -> String:
    if active_quest.is_empty():
        return "No active quest to clear."

    var old_title: String = str(active_quest.get("title", "Quest"))
    active_quest = {}
    state_changed.emit()
    return "Cleared active quest: %s" % old_title


func encourage_active_quest_from_town() -> String:
    if not has_active_quest():
        return "No active quest to encourage."

    if is_active_quest_encouraged():
        return "Quest is already encouraged: %s" % get_quest_encouragement_status_text()

    var cost: int = int(active_quest.get("encouragement_cost_gold", QUEST_ENCOURAGEMENT_COST_GOLD))
    if money < cost:
        return "Not enough village funds to encourage quest. Need %dg." % cost

    if not spend_money(cost):
        return "Could not pay quest encouragement cost."

    active_quest["encouragement_active"] = true
    active_quest["encouragement_until_day"] = _get_current_day_number_for_visitors() + QUEST_ENCOURAGEMENT_DURATION_DAYS
    active_quest["encouragement_total_spent"] = int(active_quest.get("encouragement_total_spent", 0)) + cost
    active_quest["encouragement_count"] = int(active_quest.get("encouragement_count", 0)) + 1
    active_quest["last_event"] = "Town spent %dg to encourage adventurers toward this quest." % cost
    active_quest["last_feedback"] = "Quest encouraged: notices/messengers paid %dg." % cost

    record_quest_encouragement_outflow(cost, "encourage_active_quest")
    log_quest_event("encouraged", str(active_quest.get("last_feedback", "")), "Town")
    state_changed.emit()
    return "Quest encouraged for %dg. Adventurers are more likely to pursue it." % cost

func is_active_quest_encouraged() -> bool:
    if not has_active_quest():
        return false

    if not bool(active_quest.get("encouragement_active", false)):
        return false

    var until_day: int = int(active_quest.get("encouragement_until_day", 0))
    if until_day < _get_current_day_number_for_visitors():
        active_quest["encouragement_active"] = false
        active_quest["last_event"] = "Quest encouragement expired."
        return false

    return true

func get_quest_encouragement_status_text() -> String:
    if not has_active_quest():
        return "Encouragement: No active quest."

    if is_active_quest_encouraged():
        return "Encouragement: ACTIVE until Day %d | Cost %dg | Total Spent %dg | Influence, not direct control." % [
            int(active_quest.get("encouragement_until_day", 0)),
            int(active_quest.get("encouragement_cost_gold", QUEST_ENCOURAGEMENT_COST_GOLD)),
            int(active_quest.get("encouragement_total_spent", 0))
        ]

    return "Encouragement: OFF | Cost %dg | Use only when the problem is worth town funds." % int(active_quest.get("encouragement_cost_gold", QUEST_ENCOURAGEMENT_COST_GOLD))

func _should_traveler_follow_quest_encouragement(traveler: Dictionary) -> bool:
    if not is_active_quest_encouraged():
        return false

    if str(active_quest.get("quest_type", "")) != QUEST_TYPE_HUNT_SLIMES:
        return false

    var status: String = str(traveler.get("status", ""))
    return _is_outbound_status(status) or status == "FightingVisibleSlime"

func _get_traveler_quest_speed_multiplier(traveler: Dictionary) -> float:
    if _should_traveler_follow_quest_encouragement(traveler):
        return QUEST_ENCOURAGED_SPEED_MULTIPLIER

    return 1.0

func _get_traveler_quest_cooldown_multiplier(traveler: Dictionary) -> float:
    if _should_traveler_follow_quest_encouragement(traveler):
        return QUEST_ENCOURAGED_COOLDOWN_MULTIPLIER

    return 1.0

func record_slime_defeated_for_quest(contributor_name: String = "Adventurer", contributor_data: Dictionary = {}) -> String:
    if not has_active_quest():
        return ""

    if str(active_quest.get("quest_type", "")) != QUEST_TYPE_HUNT_SLIMES:
        return ""

    var current_progress: int = int(active_quest.get("progress_count", 0))
    var target_count: int = maxi(1, int(active_quest.get("target_count", DEFAULT_SLIME_HUNT_TARGET)))
    current_progress = mini(current_progress + 1, target_count)

    var contributor_kills: Dictionary = active_quest.get("contributor_kills", {})
    contributor_kills[contributor_name] = int(contributor_kills.get(contributor_name, 0)) + 1
    active_quest["contributor_kills"] = contributor_kills

    var progress_events: Array = active_quest.get("progress_events", [])
    progress_events.append({
        "day": _get_current_day_number_for_visitors(),
        "contributor_name": contributor_name,
        "progress": current_progress,
        "target": target_count
    })
    active_quest["progress_events"] = progress_events

    active_quest["progress_count"] = current_progress
    active_quest["last_event"] = "%s defeated a Slime. Quest progress %d/%d." % [
        contributor_name,
        current_progress,
        target_count
    ]
    active_quest["last_feedback"] = "Quest +1: %s (%d/%d)" % [
        contributor_name,
        current_progress,
        target_count
    ]

    log_quest_event("progress", str(active_quest.get("last_feedback", "")), contributor_name)

    var result: String = "progress"
    if current_progress >= target_count:
        _complete_active_quest(contributor_name, contributor_data)
        result = "completed"

    state_changed.emit()
    return result

func _complete_active_quest(contributor_name: String = "Adventurer", contributor_data: Dictionary = {}) -> void:
    if active_quest.is_empty():
        return

    var reward_gold: int = int(active_quest.get("reward_gold", DEFAULT_SLIME_HUNT_REWARD_GOLD))
    var distribution: Dictionary = _build_quest_reward_distribution(reward_gold, contributor_name)
    _pay_quest_reward_distribution(distribution, contributor_data)

    active_quest["status"] = QUEST_STATUS_COMPLETED
    active_quest["completed_day"] = _get_current_day_number_for_visitors()
    active_quest["reward_paid_to_adventurers"] = true
    active_quest["reward_distribution"] = distribution
    active_quest["last_event"] = "%s completed the quest. Reward %dg paid to adventurer(s)." % [
        contributor_name,
        reward_gold
    ]
    active_quest["last_feedback"] = "Quest Complete: %s | Reward paid to adventurer(s): %s" % [
        str(active_quest.get("title", "Quest")),
        _format_quest_reward_distribution(distribution)
    ]

    log_quest_event("completed", str(active_quest.get("last_feedback", "")), contributor_name)

    var completed_record: Dictionary = active_quest.duplicate(true)
    completed_record["reward_paid"] = true
    completed_quest_log.append(completed_record)

    while completed_quest_log.size() > 10:
        completed_quest_log.remove_at(0)

    active_quest = {}

func _build_quest_reward_distribution(reward_gold: int, final_contributor_name: String) -> Dictionary:
    var distribution: Dictionary = {}
    var contributor_kills: Dictionary = active_quest.get("contributor_kills", {})

    if contributor_kills.is_empty():
        distribution[final_contributor_name] = reward_gold
        return distribution

    var total_kills: int = 0
    for contributor_name in contributor_kills.keys():
        total_kills += maxi(0, int(contributor_kills[contributor_name]))

    if total_kills <= 0:
        distribution[final_contributor_name] = reward_gold
        return distribution

    var assigned_total: int = 0
    for contributor_name in contributor_kills.keys():
        var share: int = int(floor(float(reward_gold) * float(contributor_kills[contributor_name]) / float(total_kills)))
        if share > 0:
            distribution[str(contributor_name)] = share
            assigned_total += share

    var remainder: int = reward_gold - assigned_total
    if remainder > 0:
        distribution[final_contributor_name] = int(distribution.get(final_contributor_name, 0)) + remainder

    return distribution

func _pay_quest_reward_distribution(distribution: Dictionary, contributor_data: Dictionary = {}) -> void:
    for contributor_name in distribution.keys():
        var amount: int = int(distribution[contributor_name])
        if amount <= 0:
            continue

        _award_quest_reward_to_named_adventurer(str(contributor_name), amount, contributor_data)
        record_quest_reward_injection(amount, str(contributor_name))

func _award_quest_reward_to_named_adventurer(contributor_name: String, amount: int, contributor_data: Dictionary = {}) -> void:
    if amount <= 0:
        return

    var contributor_id: int = int(contributor_data.get("id", -999999))
    var contributor_visitor_id: int = int(contributor_data.get("visitor_id", -999999))
    var contributor_matches: bool = str(contributor_data.get("display_name", "")) == contributor_name

    if contributor_matches:
        contributor_data["gold"] = int(contributor_data.get("gold", 0)) + amount
        contributor_data["quest_reward_gold"] = int(contributor_data.get("quest_reward_gold", 0)) + amount

    for index in range(world_travelers.size()):
        var traveler: Dictionary = world_travelers[index]
        var same_world_id: bool = contributor_id >= 0 and int(traveler.get("id", -1)) == contributor_id
        if same_world_id or str(traveler.get("display_name", "")) == contributor_name:
            traveler["gold"] = int(traveler.get("gold", 0)) + amount
            traveler["quest_reward_gold"] = int(traveler.get("quest_reward_gold", 0)) + amount
            traveler["floating_event_text"] = "+%dg Quest" % amount
            world_travelers[index] = traveler
            break

    for index in range(returned_travelers.size()):
        var returned: Dictionary = returned_travelers[index]
        var same_returned_visitor: bool = contributor_visitor_id >= 0 and int(returned.get("visitor_id", -1)) == contributor_visitor_id
        if same_returned_visitor or str(returned.get("display_name", "")) == contributor_name:
            returned["gold"] = int(returned.get("gold", 0)) + amount
            returned["quest_reward_gold"] = int(returned.get("quest_reward_gold", 0)) + amount
            returned_travelers[index] = returned
            break

    for index in range(visitor_pool.size()):
        var visitor: Dictionary = visitor_pool[index]
        var same_visitor_id: bool = contributor_visitor_id >= 0 and int(visitor.get("visitor_id", -1)) == contributor_visitor_id
        if same_visitor_id or str(visitor.get("display_name", "")) == contributor_name:
            visitor["gold"] = int(visitor.get("gold", 0)) + amount
            visitor["quest_reward_gold"] = int(visitor.get("quest_reward_gold", 0)) + amount
            visitor_pool[index] = visitor
            break

func _format_quest_reward_distribution(distribution: Dictionary) -> String:
    if distribution.is_empty():
        return "none"

    var parts: Array[String] = []
    for contributor_name in distribution.keys():
        parts.append("%s +%dg" % [
            str(contributor_name),
            int(distribution[contributor_name])
        ])

    return ", ".join(parts)

func get_active_quest_status_text() -> String:
    if not has_active_quest():
        return "No active quest."

    var progress_count: int = int(active_quest.get("progress_count", 0))
    var target_count: int = maxi(1, int(active_quest.get("target_count", DEFAULT_SLIME_HUNT_TARGET)))
    return "%s | %s | Progress %d/%d | Reward %dg | %s | %s" % [
        str(active_quest.get("title", "Quest")),
        str(active_quest.get("status", "unknown")),
        progress_count,
        target_count,
        int(active_quest.get("reward_gold", DEFAULT_SLIME_HUNT_REWARD_GOLD)),
        get_quest_encouragement_status_text(),
        str(active_quest.get("last_event", "No quest events yet."))
    ]

func get_completed_quest_summary_text() -> String:
    if completed_quest_log.is_empty():
        return "Completed Quests: None"

    var latest: Dictionary = completed_quest_log[completed_quest_log.size() - 1]
    return "Completed Quests: %d | Last: %s Day %d Reward %dg to adventurer(s): %s" % [
        completed_quest_log.size(),
        str(latest.get("title", "Quest")),
        int(latest.get("completed_day", 0)),
        int(latest.get("reward_gold", 0)),
        _format_quest_reward_distribution(latest.get("reward_distribution", {}))
    ]

func get_quest_board_status_text() -> String:
    return "QUEST BOARD PLACEHOLDER\nActive: %s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n\nCurrent objective: hunt visible Slimes. Future Hunt dropdowns will use discovered monsters/known nests. Quest rewards are paid to contributing adventurer(s). Encouragement costs town funds and increases adventurer interest without removing agency." % [
        get_active_quest_status_text(),
        get_completed_quest_summary_text(),
        get_last_quest_feedback_text(),
        get_quest_event_log_text(4),
        get_quest_encouragement_economy_status_text(),
        get_quest_reward_spending_loop_status_text(),
        get_adventurer_quest_reward_wallet_status_text(),
        "Strategic Warning: Some threats may resolve naturally; encouragement is for problems worth intervention."
    ]

func get_known_adventurer_registry_entries(max_entries: int = 8) -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    var shown: int = 0

    for visitor in visitor_pool:
        if not bool(visitor.get("known_to_guild", false)):
            continue

        entries.append(visitor.duplicate(true))
        shown += 1

        if shown >= max_entries:
            break

    return entries

func toggle_known_adventurer_favorite_by_id(visitor_id: int) -> String:
    var index: int = _find_visitor_index_by_id(visitor_id)
    if index < 0:
        return "Known adventurer not found."

    var visitor: Dictionary = visitor_pool[index].duplicate(true)
    if not bool(visitor.get("known_to_guild", false)):
        return "Adventurer is not known to the guild yet."

    var is_favorite: bool = not bool(visitor.get("favorite_placeholder", false))
    visitor["favorite_placeholder"] = is_favorite
    visitor_pool[index] = visitor

    var message: String = "%s %s favorite placeholder." % [
        str(visitor.get("display_name", "Visitor")),
        "marked as" if is_favorite else "removed from"
    ]
    log_visitor_event("favorite_placeholder", str(visitor.get("display_name", "Visitor")), "favorite=%s" % str(is_favorite))
    state_changed.emit()
    return message

func mark_priority_return_by_id(visitor_id: int) -> String:
    var index: int = _find_visitor_index_by_id(visitor_id)
    if index < 0:
        return "Known adventurer not found."

    var target: Dictionary = visitor_pool[index]
    if not bool(target.get("known_to_guild", false)):
        return "Adventurer is not known to the guild yet."

    if str(target.get("roster_role", "visitor")) == "resident_placeholder":
        return "Resident adventurers do not need priority return."

    for i in range(visitor_pool.size()):
        var visitor: Dictionary = visitor_pool[i].duplicate(true)
        visitor["priority_invite_placeholder"] = i == index
        visitor_pool[i] = visitor

    var message: String = "%s marked for priority return placeholder." % str(target.get("display_name", "Visitor"))
    log_visitor_event("priority_return_placeholder", str(target.get("display_name", "Visitor")), "priority return marked")
    state_changed.emit()
    return message

func contract_known_adventurer_by_id(visitor_id: int) -> String:
    var index: int = _find_visitor_index_by_id(visitor_id)
    if index < 0:
        return "Known adventurer not found."

    var visitor: Dictionary = visitor_pool[index].duplicate(true)
    if not _is_contract_candidate(visitor):
        return "%s is not an eligible contract candidate yet." % str(visitor.get("display_name", "Visitor"))

    visitor["roster_role"] = "resident_placeholder"
    visitor["status"] = "resident_placeholder"
    visitor["contract_status"] = "contracted_placeholder"
    visitor["resident_placeholder"] = true
    visitor["house_request_status"] = "needs_house_placeholder"
    visitor["assigned_house_id"] = ""
    visitor["priority_invite_placeholder"] = false
    visitor["departure_reason"] = "contracted_resident_placeholder"
    visitor_pool[index] = visitor

    var name_text: String = str(visitor.get("display_name", "Visitor"))
    log_visitor_event("resident_contract_placeholder", name_text, "requested house placeholder")
    state_changed.emit()
    return "%s became a resident placeholder and requested a house." % name_text

func get_known_adventurer_count() -> int:
    var count: int = 0
    for visitor in visitor_pool:
        if bool(visitor.get("known_to_guild", false)):
            count += 1
    return count

func get_favorite_known_adventurer_count() -> int:
    var count: int = 0
    for visitor in visitor_pool:
        if bool(visitor.get("known_to_guild", false)) and bool(visitor.get("favorite_placeholder", false)):
            count += 1
    return count


func get_contract_candidate_count() -> int:
    var count: int = 0
    for visitor in visitor_pool:
        if _is_contract_candidate(visitor):
            count += 1
    return count

func get_resident_placeholder_count() -> int:
    var count: int = 0

    for visitor in visitor_pool:
        if str(visitor.get("roster_role", "visitor")) == "resident_placeholder":
            count += 1

    for adventurer in adventurers:
        if adventurer != null and str(_safe_get_property(adventurer, "roster_role", "visitor")) == "resident_placeholder":
            count += 1

    return count

func _is_contract_candidate(visitor: Dictionary) -> bool:
    if not bool(visitor.get("known_to_guild", false)):
        return false

    if str(visitor.get("roster_role", "visitor")) == "resident_placeholder":
        return false

    if not bool(visitor.get("favorite_placeholder", false)):
        return false

    var happiness_value: int = int(visitor.get("happiness", 0))
    var total_visits_value: int = int(visitor.get("total_visits", 0))

    return happiness_value >= 0 and total_visits_value >= 1

func get_contract_candidate_text() -> String:
    var count: int = get_contract_candidate_count()
    if count <= 0:
        return "Contract Candidates: None"

    var names: Array[String] = []
    for visitor in visitor_pool:
        if _is_contract_candidate(visitor):
            names.append("%s visits:%d happiness:%d" % [
                str(visitor.get("display_name", "Visitor")),
                int(visitor.get("total_visits", 0)),
                int(visitor.get("happiness", 0))
            ])

    return "Contract Candidates: %d\n%s" % [
        count,
        "\n".join(names.slice(0, 5))
    ]

func contract_first_eligible_favorite_placeholder() -> String:
    for index in range(visitor_pool.size()):
        var visitor: Dictionary = visitor_pool[index].duplicate(true)
        if not _is_contract_candidate(visitor):
            continue

        visitor["roster_role"] = "resident_placeholder"
        visitor["status"] = "resident_placeholder"
        visitor["contract_status"] = "contracted_placeholder"
        visitor["resident_placeholder"] = true
        visitor["house_request_status"] = "needs_house_placeholder"
        visitor["assigned_house_id"] = ""
        visitor["priority_invite_placeholder"] = false
        visitor["departure_reason"] = "contracted_resident_placeholder"
        visitor_pool[index] = visitor

        var name_text: String = str(visitor.get("display_name", "Visitor"))
        log_visitor_event("resident_contract_placeholder", name_text, "requested house placeholder")
        state_changed.emit()
        return "%s became a resident placeholder and requested a house." % name_text

    return "No eligible favorite contract candidate. Mark a known adventurer as favorite first."

func get_resident_contract_status_text() -> String:
    return "Residents: %d | Contract Candidates: %d | Housing Requests: %d" % [
        get_resident_placeholder_count(),
        get_contract_candidate_count(),
        get_house_request_placeholder_count()
    ]

func get_house_request_placeholder_count() -> int:
    var count: int = 0
    for visitor in visitor_pool:
        if str(visitor.get("house_request_status", "")) == "needs_house_placeholder":
            count += 1
    return count

func get_house_request_placeholder_text() -> String:
    var names: Array[String] = []
    for visitor in visitor_pool:
        if str(visitor.get("house_request_status", "")) == "needs_house_placeholder":
            names.append(str(visitor.get("display_name", "Visitor")))

    if names.is_empty():
        return "House Requests: None"

    return "House Requests: %s" % ", ".join(names.slice(0, 5))

func get_priority_return_candidate_text() -> String:
    for visitor in visitor_pool:
        if bool(visitor.get("priority_invite_placeholder", false)):
            return "Priority Return: %s | Status:%s | Visits:%d | Last Reason:%s" % [
                str(visitor.get("display_name", "Visitor")),
                str(visitor.get("status", "unknown")),
                int(visitor.get("total_visits", 0)),
                str(visitor.get("departure_reason", "none"))
            ]

    return "Priority Return: None"

func get_known_adventurer_registry_text(max_entries: int = 8) -> String:
    if visitor_pool.is_empty():
        return "Known Adventurers: 0\nNo known adventurers registered yet."

    var lines: Array[String] = []
    var shown: int = 0

    for visitor in visitor_pool:
        if not bool(visitor.get("known_to_guild", false)):
            continue

        var favorite_text: String = "Fav" if bool(visitor.get("favorite_placeholder", false)) else "-"
        var priority_text: String = "Priority" if bool(visitor.get("priority_invite_placeholder", false)) else "-"
        var contract_text: String = str(visitor.get("contract_status", "no_contract"))
        var house_text: String = str(visitor.get("house_request_status", "no_house_request"))
        lines.append("%s | Visits:%d | %s | Last:%s | %s | %s | %s | %s" % [
            str(visitor.get("display_name", "Visitor")),
            int(visitor.get("total_visits", 0)),
            str(visitor.get("status", "unknown")),
            str(visitor.get("departure_reason", "none")),
            favorite_text,
            priority_text,
            contract_text,
            house_text
        ])
        shown += 1

        if shown >= max_entries:
            break

    if lines.is_empty():
        return "Known Adventurers: 0\nNo known adventurers registered yet."

    var remaining: int = maxi(get_known_adventurer_count() - shown, 0)
    var extra_text: String = ""
    if remaining > 0:
        extra_text = "\n...and %d more known adventurer(s)." % remaining

    return "Known Adventurers: %d | Favorites: %d | %s\n%s%s\n%s\n%s\n%s" % [
        get_known_adventurer_count(),
        get_favorite_known_adventurer_count(),
        get_resident_contract_status_text(),
        "\n".join(lines),
        extra_text,
        get_priority_return_candidate_text(),
        get_contract_candidate_text(),
        get_house_request_placeholder_text()
    ]

func toggle_first_known_adventurer_favorite_placeholder() -> String:
    var index: int = _find_first_known_adventurer_index()
    if index < 0:
        return "No known adventurer to mark as favorite."

    var visitor: Dictionary = visitor_pool[index].duplicate(true)
    var is_favorite: bool = not bool(visitor.get("favorite_placeholder", false))
    visitor["favorite_placeholder"] = is_favorite
    visitor_pool[index] = visitor

    var message: String = "%s %s favorite placeholder." % [
        str(visitor.get("display_name", "Visitor")),
        "marked as" if is_favorite else "removed from"
    ]
    log_visitor_event("favorite_placeholder", str(visitor.get("display_name", "Visitor")), "favorite=%s" % str(is_favorite))
    state_changed.emit()
    return message

func mark_priority_return_placeholder() -> String:
    var index: int = _find_best_priority_return_candidate_index()
    if index < 0:
        return "No known adventurer available for priority return."

    for i in range(visitor_pool.size()):
        var visitor: Dictionary = visitor_pool[i].duplicate(true)
        visitor["priority_invite_placeholder"] = i == index
        visitor_pool[i] = visitor

    var chosen: Dictionary = visitor_pool[index]
    var message: String = "%s marked for priority return placeholder." % str(chosen.get("display_name", "Visitor"))
    log_visitor_event("priority_return_placeholder", str(chosen.get("display_name", "Visitor")), "priority return marked")
    state_changed.emit()
    return message

func _find_first_known_adventurer_index() -> int:
    for index in range(visitor_pool.size()):
        if bool(visitor_pool[index].get("known_to_guild", false)):
            return index

    return -1

func _find_best_priority_return_candidate_index() -> int:
    for index in range(visitor_pool.size()):
        var visitor: Dictionary = visitor_pool[index]
        if bool(visitor.get("known_to_guild", false)) and bool(visitor.get("favorite_placeholder", false)) and str(visitor.get("status", "available")) == "available" and str(visitor.get("roster_role", "visitor")) != "resident_placeholder":
            return index

    for index in range(visitor_pool.size()):
        var visitor: Dictionary = visitor_pool[index]
        if bool(visitor.get("known_to_guild", false)) and bool(visitor.get("favorite_placeholder", false)) and str(visitor.get("roster_role", "visitor")) != "resident_placeholder":
            return index

    for index in range(visitor_pool.size()):
        var visitor: Dictionary = visitor_pool[index]
        if bool(visitor.get("known_to_guild", false)) and str(visitor.get("status", "available")) == "available" and str(visitor.get("roster_role", "visitor")) != "resident_placeholder":
            return index

    return _find_first_known_adventurer_index()

func _find_priority_available_visitor_index() -> int:
    for index in range(visitor_pool.size()):
        var visitor: Dictionary = visitor_pool[index]
        if str(visitor.get("status", "available")) == "available" and bool(visitor.get("priority_invite_placeholder", false)):
            return index

    return -1

func request_visitor_for_spawn(fallback_name: String = "Visitor") -> Dictionary:
    if not can_spawn_regional_visitor():
        log_visitor_event("spawn_blocked", fallback_name, get_visitor_cap_warning_text())
        return {}

    var visitor_index: int = _find_priority_available_visitor_index()
    var visitor_data: Dictionary = {}
    var is_new_visitor: bool = false
    var used_priority_return: bool = visitor_index >= 0

    if visitor_index < 0:
        visitor_index = _find_available_visitor_index()

    if visitor_index >= 0:
        visitor_data = visitor_pool[visitor_index].duplicate(true)
    else:
        visitor_data = _create_new_visitor_pool_record(fallback_name)
        visitor_pool.append(visitor_data.duplicate(true))
        visitor_index = visitor_pool.size() - 1
        is_new_visitor = true

    var current_day: int = _get_current_day_number_for_visitors()
    visitor_data["status"] = "active"
    visitor_data["visit_start_day"] = current_day
    visitor_data["visit_days_limit"] = _roll_visitor_days_limit()
    visitor_data["total_visits"] = int(visitor_data.get("total_visits", 0)) + 1
    visitor_data["last_spawn_day"] = current_day
    visitor_data["departure_reason"] = ""
    visitor_data["last_spawn_event"] = "new" if is_new_visitor else "returning"
    if used_priority_return:
        visitor_data["last_spawn_event"] = "priority_return"
        visitor_data["priority_invite_placeholder"] = false
    visitor_data["known_to_guild"] = true
    visitor_data["registration_day"] = int(visitor_data.get("registration_day", current_day))

    visitor_pool[visitor_index] = visitor_data.duplicate(true)

    if is_new_visitor:
        log_visitor_event("new_registration", str(visitor_data.get("display_name", "Visitor")), "registered at Guild Hall")
    elif used_priority_return:
        log_visitor_event("priority_return", str(visitor_data.get("display_name", "Visitor")), "returned due to priority placeholder")
    else:
        log_visitor_event("returning_visitor", str(visitor_data.get("display_name", "Visitor")), "returned from visitor pool")

    state_changed.emit()
    return visitor_data

func release_visitor_to_pool_from_adventurer(adventurer: Node, reason: String = "visit_complete") -> void:
    if adventurer == null:
        return

    var visitor_id: int = int(_safe_get_property(adventurer, "visitor_id", -1))
    if visitor_id < 0:
        return

    var visitor_data: Dictionary = _visitor_record_from_adventurer(adventurer)
    visitor_data["status"] = "available"
    visitor_data["departure_reason"] = reason
    visitor_data["last_departure_day"] = _get_current_day_number_for_visitors()

    var existing_index: int = _find_visitor_index_by_id(visitor_id)
    if existing_index >= 0:
        visitor_pool[existing_index] = visitor_data.duplicate(true)
    else:
        visitor_pool.append(visitor_data.duplicate(true))

    var departed_name: String = str(visitor_data.get("display_name", "Visitor"))
    departed_visitor_history.append({
        "visitor_id": visitor_id,
        "display_name": departed_name,
        "departure_day": _get_current_day_number_for_visitors(),
        "reason": reason
    })

    log_visitor_event("departure", departed_name, reason)

    if departed_visitor_history.size() > 30:
        departed_visitor_history.remove_at(0)

    state_changed.emit()

func get_visitor_departure_reason_for_adventurer(adventurer: Node) -> String:
    if adventurer == null:
        return ""

    var roster_role: String = str(_safe_get_property(adventurer, "roster_role", "visitor"))
    if roster_role == "resident_placeholder":
        return ""

    var visitor_id: int = int(_safe_get_property(adventurer, "visitor_id", -1))
    if visitor_id < 0:
        return ""

    var trip_count: int = int(_safe_get_property(adventurer, "trip_count", 0))
    var max_trip_count: int = maxi(1, int(_safe_get_property(adventurer, "max_trip_count", 2)))
    if trip_count >= max_trip_count:
        return "debug_max_trips_complete"

    var start_day: int = int(_safe_get_property(adventurer, "visitor_visit_start_day", _get_current_day_number_for_visitors()))
    var limit: int = maxi(1, int(_safe_get_property(adventurer, "visitor_visit_days_limit", VISITOR_MIN_VISIT_DAYS)))
    var days_present: int = maxi(1, _get_current_day_number_for_visitors() - start_day + 1)

    if days_present >= limit:
        return "visit_days_complete"

    return ""

func should_visitor_depart(adventurer: Node) -> bool:
    return get_visitor_departure_reason_for_adventurer(adventurer) != ""

func _create_new_visitor_pool_record(fallback_name: String) -> Dictionary:
    var name_index: int = (next_visitor_id - 1) % VISITOR_POOL_TEMPLATE_NAMES.size()
    var chosen_name: String = fallback_name
    if chosen_name == "" or chosen_name == "Visitor":
        chosen_name = VISITOR_POOL_TEMPLATE_NAMES[name_index]

    var visitor_data: Dictionary = {
        "visitor_id": next_visitor_id,
        "display_name": chosen_name,
        "class_id": "fighter",
        "level": 1,
        "gold": 50,
        "quest_reward_gold": 0,
        "happiness": 0,
        "status": "available",
        "roster_role": "visitor",
        "visit_start_day": _get_current_day_number_for_visitors(),
        "visit_days_limit": _roll_visitor_days_limit(),
        "total_visits": 0,
        "departure_reason": "",
        "last_spawn_event": "new",
        "known_to_guild": true,
        "registration_day": _get_current_day_number_for_visitors(),
        "priority_invite_placeholder": false,
        "favorite_placeholder": false,
        "contract_status": "no_contract",
        "resident_placeholder": false,
        "house_request_status": "no_house_request",
        "assigned_house_id": "",
        "max_trip_count": 2
    }

    next_visitor_id += 1
    return visitor_data

func _visitor_record_from_adventurer(adventurer: Node) -> Dictionary:
    return {
        "visitor_id": int(_safe_get_property(adventurer, "visitor_id", -1)),
        "display_name": str(_safe_get_property(adventurer, "display_name", "Visitor")),
        "class_id": str(_safe_get_property(adventurer, "class_id", "fighter")),
        "level": int(_safe_get_property(adventurer, "level", 1)),
        "gold": int(_safe_get_property(adventurer, "gold", 0)),
        "quest_reward_gold": int(_safe_get_property(adventurer, "quest_reward_gold", 0)),
        "happiness": int(_safe_get_property(adventurer, "happiness", 0)),
        "status": "available",
        "roster_role": str(_safe_get_property(adventurer, "roster_role", "visitor")),
        "visit_start_day": int(_safe_get_property(adventurer, "visitor_visit_start_day", _get_current_day_number_for_visitors())),
        "visit_days_limit": int(_safe_get_property(adventurer, "visitor_visit_days_limit", VISITOR_MIN_VISIT_DAYS)),
        "total_visits": int(_safe_get_property(adventurer, "visitor_total_visits", 1)),
        "departure_reason": str(_safe_get_property(adventurer, "departure_reason_placeholder", "")),
        "known_to_guild": true,
        "registration_day": int(_safe_get_property(adventurer, "visitor_registration_day", _get_current_day_number_for_visitors())),
        "priority_invite_placeholder": bool(_safe_get_property(adventurer, "priority_invite_placeholder", false)),
        "favorite_placeholder": bool(_safe_get_property(adventurer, "favorite_placeholder", false)),
        "contract_status": str(_safe_get_property(adventurer, "contract_status", "no_contract")),
        "resident_placeholder": str(_safe_get_property(adventurer, "roster_role", "visitor")) == "resident_placeholder",
        "house_request_status": str(_safe_get_property(adventurer, "house_request_status", "no_house_request")),
        "assigned_house_id": str(_safe_get_property(adventurer, "assigned_house_id", "")),
        "max_trip_count": int(_safe_get_property(adventurer, "max_trip_count", 2))
    }

func _find_available_visitor_index() -> int:
    for index in range(visitor_pool.size()):
        if str(visitor_pool[index].get("status", "available")) == "available":
            return index
    return -1

func _find_visitor_index_by_id(visitor_id: int) -> int:
    for index in range(visitor_pool.size()):
        if int(visitor_pool[index].get("visitor_id", -1)) == visitor_id:
            return index
    return -1

func _roll_visitor_days_limit() -> int:
    return randi_range(VISITOR_MIN_VISIT_DAYS, VISITOR_MAX_VISIT_DAYS)

func _get_current_day_number_for_visitors() -> int:
    var clock_node := get_node_or_null("/root/GameClock")
    if clock_node != null and clock_node.has_method("get"):
        return int(clock_node.get("day_number"))

    return 1

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
        "quest_reward_gold": _safe_get_property(adventurer, "quest_reward_gold", 0),
        "inventory": _safe_get_property(adventurer, "inventory", {}).duplicate(true),
        "trip_count": _safe_get_property(adventurer, "trip_count", 0),
        "max_trip_count": _safe_get_property(adventurer, "max_trip_count", 2),
        "visitor_id": _safe_get_property(adventurer, "visitor_id", -1),
        "visitor_visit_start_day": _safe_get_property(adventurer, "visitor_visit_start_day", 1),
        "visitor_visit_days_limit": _safe_get_property(adventurer, "visitor_visit_days_limit", VISITOR_MIN_VISIT_DAYS),
        "visitor_total_visits": _safe_get_property(adventurer, "visitor_total_visits", 1),
        "roster_role": _safe_get_property(adventurer, "roster_role", "visitor"),
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
        var q_gold: int = int(traveler.get("quest_reward_gold", 0))
        summary_parts.append("%s:%s T%d/%d E%d K%d QG%d" % [traveler_name, status, trip_count, max_trip_count, energy, kills, q_gold])

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
        var q_gold: int = int(traveler.get("quest_reward_gold", 0))
        var q_text: String = " QG%d" % q_gold if q_gold > 0 else ""

        if sale_message != "":
            summary_parts.append("%s:%s T%d/%d E%d%s %s" % [traveler_name, status, trip_count, max_trip_count, energy, q_text, sale_message])
        else:
            summary_parts.append("%s:%s T%d/%d E%d%s" % [traveler_name, status, trip_count, max_trip_count, energy, q_text])

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
    discover_slime_threats("slime_sighted")
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
                    var encouraged_speed: float = WORLD_TRAVELER_SPEED * _get_traveler_quest_speed_multiplier(traveler)
                    if _should_traveler_follow_quest_encouragement(traveler) and not bool(traveler.get("quest_encouragement_noted", false)):
                        traveler["quest_encouragement_noted"] = true
                        traveler["floating_event_text"] = "Quest Notice"
                        traveler["last_combat_log"] = "Quest notice encouraged this outing."
                    var moved_to_slime: bool = _move_traveler_toward_target(traveler, slime_position, encouraged_speed, delta)
                    changed = moved_to_slime or changed

                    if _traveler_reached_position(traveler, slime_position):
                        _start_visible_slime_combat(traveler, int(target_slime.get("id", -1)), "targeted")
                        _mark_slime_engaged(int(target_slime.get("id", -1)), int(traveler.get("id", -1)))
                        changed = true
                else:
                    var nest_speed: float = WORLD_TRAVELER_SPEED * _get_traveler_quest_speed_multiplier(traveler)
                    if _should_traveler_follow_quest_encouragement(traveler) and not bool(traveler.get("quest_encouragement_noted", false)):
                        traveler["quest_encouragement_noted"] = true
                        traveler["floating_event_text"] = "Quest Notice"
                        traveler["last_combat_log"] = "Quest notice encouraged this outing."
                    var moved_to_nest: bool = _move_traveler_toward_target(traveler, SLIME_NEST_WORLD_POSITION, nest_speed, delta)
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
        var cooldown_delta: float = delta / _get_traveler_quest_cooldown_multiplier(traveler)
        traveler["combat_cooldown_timer"] = maxf(cooldown - cooldown_delta, 0.0)

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

    var quest_result: String = ""

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
        quest_result = record_slime_defeated_for_quest(str(traveler.get("display_name", "Adventurer")), traveler)

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

        if quest_result == "completed":
            traveler["floating_event_text"] = "Quest Complete! +Gold"
        elif quest_result == "progress":
            traveler["floating_event_text"] = "Quest +1"
        elif str(traveler.get("status", "")) == "FleeingToTown":
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
            discover_slime_threats("slime_defeated")
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
