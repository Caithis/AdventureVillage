extends Node
class_name AdventurerAI

var current_state: String = "Idle"

@onready var adventurer: Adventurer = get_parent() as Adventurer

func _ready() -> void:
    set_state("Idle")

func set_state(new_state: String) -> void:
    current_state = new_state

    if adventurer != null and adventurer.has_method("set_state"):
        adventurer.set_state(current_state)

func get_state() -> String:
    return current_state
