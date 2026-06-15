extends Node2D
class_name Adventurer

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

func _ready() -> void:
    _refresh_label()

func _exit_tree() -> void:
    if Engine.is_editor_hint():
        return

    if is_node_ready():
        GameState.unregister_adventurer(self)

func setup_placeholder(new_display_name: String, new_class_id: String, new_level: int) -> void:
    display_name = new_display_name
    class_id = new_class_id
    level = new_level
    name = "Adventurer_%s" % display_name

    if ai != null and ai.has_method("set_state"):
        ai.set_state("Idle")

    _refresh_label()

func set_state(new_state: String) -> void:
    current_state = new_state
    _refresh_label()

func add_item(item_id: String, amount: int) -> void:
    if amount <= 0:
        return

    inventory[item_id] = int(inventory.get(item_id, 0)) + amount
    _refresh_label()

func spend_gold(amount: int) -> bool:
    if amount <= 0:
        return false

    if gold < amount:
        return false

    gold -= amount
    _refresh_label()
    return true

func _refresh_label() -> void:
    if name_label == null:
        return

    name_label.text = "%s Lv.%d\n%s | %dg" % [
        display_name,
        level,
        current_state,
        gold
    ]
