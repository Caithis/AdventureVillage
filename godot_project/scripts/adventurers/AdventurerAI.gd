extends Node
class_name AdventurerAI

var current_state: String = "Idle"

var general_store_position: Vector2 = Vector2.ZERO
var exit_position: Vector2 = Vector2.ZERO
var wait_timer: float = 0.0
var purchase_result_wait_seconds: float = 1.25
var leaving_town_wait_seconds: float = 0.25

@onready var adventurer: Adventurer = get_parent() as Adventurer

func _ready() -> void:
    set_state("Idle")

func _process(delta: float) -> void:
    match current_state:
        "EnterTown":
            _state_enter_town()
        "GoToGeneralStore":
            _state_go_to_general_store()
        "BuySmallPotion":
            _state_buy_small_potion()
        "BoughtPotion", "SkipPurchaseNoStock", "SkipPurchaseNoGold", "SkipPurchaseAlreadyHasPotion", "SkipPurchaseFailed":
            _state_purchase_result(delta)
        "GoToExit":
            _state_go_to_exit()
        "LeavingTown":
            _state_leaving_town(delta)
        _:
            pass

func start_town_routine(new_general_store_position: Vector2, new_exit_position: Vector2) -> void:
    general_store_position = new_general_store_position
    exit_position = new_exit_position
    set_state("EnterTown")

func set_state(new_state: String) -> void:
    current_state = new_state

    if adventurer != null and adventurer.has_method("set_state"):
        adventurer.set_state(current_state)

    match current_state:
        "EnterTown":
            pass
        "GoToGeneralStore":
            if adventurer != null:
                adventurer.set_move_target(general_store_position)
        "BuySmallPotion":
            if adventurer != null:
                adventurer.clear_move_target()
        "BoughtPotion", "SkipPurchaseNoStock", "SkipPurchaseNoGold", "SkipPurchaseAlreadyHasPotion", "SkipPurchaseFailed":
            wait_timer = purchase_result_wait_seconds
            if adventurer != null:
                adventurer.clear_move_target()
        "GoToExit":
            if adventurer != null:
                adventurer.set_move_target(exit_position)
        "LeavingTown":
            wait_timer = leaving_town_wait_seconds
            if adventurer != null:
                adventurer.clear_move_target()
        _:
            pass

func get_state() -> String:
    return current_state

func _state_enter_town() -> void:
    set_state("GoToGeneralStore")

func _state_go_to_general_store() -> void:
    if adventurer == null:
        return

    if not adventurer.has_target and adventurer.has_reached_target():
        set_state("BuySmallPotion")

func _state_buy_small_potion() -> void:
    if adventurer == null or not adventurer.has_method("try_buy_small_potion"):
        set_state("SkipPurchaseFailed")
        return

    var result := adventurer.try_buy_small_potion()

    match result:
        "bought":
            set_state("BoughtPotion")
        "no_stock":
            set_state("SkipPurchaseNoStock")
        "no_gold":
            set_state("SkipPurchaseNoGold")
        "already_has_potion":
            set_state("SkipPurchaseAlreadyHasPotion")
        _:
            set_state("SkipPurchaseFailed")

func _state_purchase_result(delta: float) -> void:
    wait_timer -= delta

    if wait_timer <= 0.0:
        set_state("GoToExit")

func _state_go_to_exit() -> void:
    if adventurer == null:
        return

    if not adventurer.has_target and adventurer.has_reached_target():
        set_state("LeavingTown")

func _state_leaving_town(delta: float) -> void:
    wait_timer -= delta

    if wait_timer <= 0.0 and adventurer != null and adventurer.has_method("enter_world_travel"):
        adventurer.enter_world_travel()
