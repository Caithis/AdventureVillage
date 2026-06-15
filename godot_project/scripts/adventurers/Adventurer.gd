extends Node2D
class_name Adventurer

const SMALL_POTION_ID := "small_potion"
const SMALL_POTION_PRICE := 15

@onready var name_label: Label = $NameLabel
@onready var ai: Node = $AdventurerAI

var display_name: String = "Rook"
var class_id: String = "fighter"
var level: int = 1
var gold: int = 50
var happiness: int = 0
var health: int = 30
var max_health: int = 30
var inventory: Dictionary = {}
var current_state: String = "Idle"
var last_purchase_message: String = ""

var movement_speed: float = 85.0
var target_position: Vector2 = Vector2.ZERO
var has_target: bool = false
var arrival_distance: float = 3.0

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

func start_town_routine(entrance_position: Vector2, general_store_position: Vector2, exit_position: Vector2) -> void:
    global_position = entrance_position
    target_position = entrance_position
    has_target = false

    if ai != null and ai.has_method("start_town_routine"):
        ai.start_town_routine(general_store_position, exit_position)

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

    var removed_from_town := GameState.remove_item(SMALL_POTION_ID, 1)
    if not removed_from_town:
        set_purchase_message("Purchase failed")
        return "failed"

    var spent_gold := spend_gold(SMALL_POTION_PRICE)
    if not spent_gold:
        # Safety rollback. This should not happen because gold is checked before removal.
        GameState.add_item(SMALL_POTION_ID, 1)
        set_purchase_message("Purchase failed")
        return "failed"

    add_item(SMALL_POTION_ID, 1)
    set_purchase_message("Bought potion")
    return "bought"

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
    var message_line := ""
    if last_purchase_message != "":
        message_line = "\n%s" % last_purchase_message

    name_label.text = "%s Lv.%d\n%s | %dg | Potions: %d%s" % [
        display_name,
        level,
        current_state,
        gold,
        potion_count,
        message_line
    ]
