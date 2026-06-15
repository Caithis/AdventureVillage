extends Node2D
class_name Adventurer

const SMALL_POTION_ID := "small_potion"
const SLIME_GEL_ID := "slime_gel"

const SMALL_POTION_PRICE := 15
const ENERGY_REST_THRESHOLD_RATIO := 0.40
const HEALTH_REST_THRESHOLD_RATIO := 0.50

@onready var name_label: Label = $NameLabel
@onready var ai: Node = $AdventurerAI

var display_name: String = "Rook"
var class_id: String = "fighter"
var level: int = 1
var gold: int = 50
var happiness: int = 0
var health: int = 30
var max_health: int = 30
var energy: int = 100
var max_energy: int = 100
var inventory: Dictionary = {}
var current_state: String = "Idle"
var last_purchase_message: String = ""
var traveler_id: int = -1
var is_returned_adventurer: bool = false
var trip_count: int = 0
var max_trip_count: int = 2
var last_night_sleep_day: int = -1

var movement_speed: float = 85.0
var target_position: Vector2 = Vector2.ZERO
var has_target: bool = false
var arrival_distance: float = 3.0
var has_entered_world_travel: bool = false

func _ready() -> void:
    target_position = global_position
    _refresh_label()

func _process(delta: float) -> void:
    _move_toward_target(delta)

func _exit_tree() -> void:
    if Engine.is_editor_hint():
        return

    GameState.unregister_adventurer(self)

func setup_placeholder(new_display_name: String, new_class_id: String, new_level: int) -> void:
    display_name = new_display_name
    class_id = new_class_id
    level = new_level
    name = "Adventurer_%s" % display_name

    if ai != null and ai.has_method("set_state"):
        ai.set_state("Idle")

    _refresh_label()

func setup_from_traveler_data(traveler_data: Dictionary) -> void:
    traveler_id = int(traveler_data.get("id", -1))
    display_name = str(traveler_data.get("display_name", "Returned"))
    class_id = str(traveler_data.get("class_id", "fighter"))
    level = int(traveler_data.get("level", 1))
    gold = int(traveler_data.get("gold", 0))
    inventory = traveler_data.get("inventory", {}).duplicate(true)
    health = int(traveler_data.get("hp", 1))
    max_health = int(traveler_data.get("max_hp", 30))
    energy = int(traveler_data.get("energy", 100))
    max_energy = int(traveler_data.get("max_energy", 100))
    trip_count = int(traveler_data.get("trip_count", 0))
    max_trip_count = int(traveler_data.get("max_trip_count", 2))
    last_night_sleep_day = int(traveler_data.get("last_night_sleep_day", -1))
    is_returned_adventurer = true
    has_entered_world_travel = false
    name = "ReturnedAdventurer_%s_%d" % [display_name, traveler_id]
    last_purchase_message = str(traveler_data.get("last_combat_log", "Returned to town."))
    _refresh_label()

func start_town_routine(entrance_position: Vector2, general_store_position: Vector2, exit_position: Vector2) -> void:
    global_position = entrance_position
    target_position = entrance_position
    has_target = false

    if ai != null and ai.has_method("start_town_routine"):
        ai.start_town_routine(general_store_position, exit_position)

func start_return_to_town_routine(spawn_position: Vector2, general_store_position: Vector2, inn_position: Vector2, exit_position: Vector2) -> void:
    global_position = spawn_position
    target_position = spawn_position
    has_target = false

    if ai != null and ai.has_method("start_return_to_town_routine"):
        ai.start_return_to_town_routine(general_store_position, inn_position, exit_position)

func set_state(new_state: String) -> void:
    current_state = new_state
    _refresh_label()

func set_purchase_message(message: String) -> void:
    last_purchase_message = message
    _refresh_label()

func set_move_target(new_target_position: Vector2) -> void:
    target_position = new_target_position
    has_target = true

func clear_move_target() -> void:
    has_target = false

func has_reached_target() -> bool:
    return global_position.distance_to(target_position) <= arrival_distance

func should_continue_adventuring() -> bool:
    return trip_count < max_trip_count

func needs_small_potion() -> bool:
    return get_item_count(SMALL_POTION_ID) <= 0

func needs_inn_rest() -> bool:
    return health <= get_health_rest_threshold() or energy <= get_energy_rest_threshold()

func is_injured() -> bool:
    return health <= get_health_rest_threshold()

func get_health_rest_threshold() -> int:
    return ceili(float(max_health) * HEALTH_REST_THRESHOLD_RATIO)

func get_energy_rest_threshold() -> int:
    return ceili(float(max_energy) * ENERGY_REST_THRESHOLD_RATIO)

func should_seek_night_sleep() -> bool:
    if GameClock.get_phase_name() != "Night":
        return false

    return last_night_sleep_day != GameClock.day_number

func rest_at_inn() -> void:
    health = max_health
    energy = max_energy
    set_purchase_message("Rested at Inn")
    _update_returned_record("RestedAtInn", "Rested at Inn. Energy restored.")
    _refresh_label()

func sleep_at_inn_for_night() -> void:
    health = max_health
    energy = max_energy
    last_night_sleep_day = GameClock.day_number
    set_purchase_message("Slept at Inn for Night")
    _update_returned_record("SleptAtInn", "Slept at Inn for Night.")
    _refresh_label()

func try_buy_small_potion() -> String:
    if get_item_count(SMALL_POTION_ID) > 0:
        set_purchase_message("Already has potion")
        return "already_has_potion"

    if not GameState.has_item(SMALL_POTION_ID, 1):
        set_purchase_message("No potions in stock")
        return "no_stock"

    if gold < SMALL_POTION_PRICE:
        set_purchase_message("Cannot afford potion")
        return "no_gold"

    var spent_gold := spend_gold(SMALL_POTION_PRICE)
    if not spent_gold:
        set_purchase_message("Purchase failed")
        return "failed"

    var removed_from_town := GameState.remove_item(SMALL_POTION_ID, 1)
    if not removed_from_town:
        gold += SMALL_POTION_PRICE
        set_purchase_message("Purchase failed")
        _refresh_label()
        return "failed"

    add_item(SMALL_POTION_ID, 1)
    GameState.add_money(SMALL_POTION_PRICE)
    set_purchase_message("Bought potion")
    return "bought"

func try_sell_slime_gel() -> String:
    var slime_gel_amount := get_item_count(SLIME_GEL_ID)

    if slime_gel_amount <= 0:
        set_purchase_message("No Slime Gel to sell")
        _update_returned_record("NoLootToSell", "No loot to sell.")
        return "no_loot"

    var sale_total := slime_gel_amount * GameState.SLIME_GEL_SELL_VALUE

    inventory[SLIME_GEL_ID] = 0
    gold += sale_total
    GameState.add_item(SLIME_GEL_ID, slime_gel_amount)

    var sale_message := "Sold %d Slime Gel for %dg" % [slime_gel_amount, sale_total]
    set_purchase_message(sale_message)
    _update_returned_record("SoldLoot", sale_message)
    _refresh_label()
    return "sold"

func _update_returned_record(new_status: String, sale_message: String) -> void:
    if traveler_id < 0:
        return

    var updated_data := {
        "id": traveler_id,
        "display_name": display_name,
        "class_id": class_id,
        "level": level,
        "gold": gold,
        "inventory": inventory.duplicate(true),
        "trip_count": trip_count,
        "max_trip_count": max_trip_count,
        "last_night_sleep_day": last_night_sleep_day,
        "energy": energy,
        "max_energy": max_energy,
        "status": new_status,
        "hp": health,
        "max_hp": max_health,
        "town_reentry_claimed": true,
        "sale_message": sale_message,
        "last_combat_log": sale_message,
    }

    GameState.update_returned_traveler_record(traveler_id, updated_data)

func enter_world_travel() -> void:
    if has_entered_world_travel:
        return

    has_entered_world_travel = true
    trip_count += 1
    set_state("LeavingTown")
    set_purchase_message("Leaving for trip %d/%d" % [trip_count, max_trip_count])
    GameState.add_world_traveler_from_adventurer(self)
    queue_free()

func add_item(item_id: String, amount: int) -> void:
    if amount <= 0:
        return

    inventory[item_id] = int(inventory.get(item_id, 0)) + amount
    _refresh_label()

func get_item_count(item_id: String) -> int:
    return int(inventory.get(item_id, 0))

func spend_gold(amount: int) -> bool:
    if amount <= 0:
        return false

    if gold < amount:
        return false

    gold -= amount
    _refresh_label()
    return true

func _move_toward_target(delta: float) -> void:
    if not has_target:
        return

    var direction := target_position - global_position
    var distance := direction.length()

    if distance <= arrival_distance:
        global_position = target_position
        has_target = false
        return

    var step := movement_speed * delta
    if step >= distance:
        global_position = target_position
        has_target = false
        return

    global_position += direction.normalized() * step

func _refresh_label() -> void:
    if name_label == null:
        return

    var potion_count := get_item_count(SMALL_POTION_ID)
    var slime_gel_count := get_item_count(SLIME_GEL_ID)
    var message_line := ""
    if last_purchase_message != "":
        message_line = "\n%s" % last_purchase_message

    name_label.text = "%s Lv.%d\n%s | %dg | HP:%d/%d E:%d/%d\nP:%d G:%d | T:%d/%d%s" % [
        display_name,
        level,
        current_state,
        gold,
        health,
        max_health,
        energy,
        max_energy,
        potion_count,
        slime_gel_count,
        trip_count,
        max_trip_count,
        message_line
    ]
