extends Node
class_name AdventurerAI

var current_state: String = "Idle"

var general_store_position: Vector2 = Vector2.ZERO
var inn_position: Vector2 = Vector2.ZERO
var exit_position: Vector2 = Vector2.ZERO
var wait_timer: float = 0.0
var purchase_result_wait_seconds: float = 1.25
var leaving_town_wait_seconds: float = 0.25
var sell_result_wait_seconds: float = 1.5
var prepare_next_trip_wait_seconds: float = 1.0
var restock_result_wait_seconds: float = 1.25
var inn_rest_seconds: float = 2.0
var inn_result_wait_seconds: float = 1.0
var night_sleep_seconds: float = 2.0
var capacity_retry_wait_seconds: float = 0.75

@onready var adventurer: Adventurer = get_parent() as Adventurer

func _ready() -> void:
    set_state("Idle")

func _process(delta: float) -> void:
    if _should_interrupt_for_night_sleep():
        set_state("GoToInnForNight")
        return

    match current_state:
        "EnterTown":
            _state_enter_town()
        "GoToGeneralStore":
            _state_go_to_general_store()
        "WaitForGeneralStoreCapacity":
            _state_wait_for_general_store_capacity(delta)
        "BuySmallPotion":
            _state_buy_small_potion()
        "BoughtPotion", "SkipPurchaseNoStock", "SkipPurchaseNoGold", "SkipPurchaseAlreadyHasPotion", "SkipPurchaseFailed":
            _state_purchase_result(delta)
        "GoToExit":
            _state_go_to_exit()
        "LeavingTown":
            _state_leaving_town(delta)
        "ReturnedToTown":
            _state_returned_to_town()
        "GoToGeneralStoreToSell":
            _state_go_to_general_store_to_sell()
        "WaitForGeneralStoreSellCapacity":
            _state_wait_for_general_store_sell_capacity(delta)
        "SellSlimeGel":
            _state_sell_slime_gel()
        "SoldLoot":
            _state_sold_loot(delta)
        "SaleBlockedMaterialBuyingOff":
            _state_sale_blocked(delta)
        "NoLootToSell":
            _state_no_loot_to_sell(delta)
        "CheckRecoveryNeed":
            _state_check_recovery_need()
        "GoToInn":
            _state_go_to_inn()
        "WaitForInnCapacity":
            _state_wait_for_inn_capacity(delta)
        "RestAtInn":
            _state_rest_at_inn(delta)
        "RestedAtInn", "SkipInnRest":
            _state_inn_result(delta)
        "GoToInnForNight":
            _state_go_to_inn_for_night()
        "WaitForNightInnCapacity":
            _state_wait_for_night_inn_capacity(delta)
        "SleepAtInn":
            _state_sleep_at_inn(delta)
        "SleptAtInn":
            _state_slept_at_inn(delta)
        "PrepareNextTrip":
            _state_prepare_next_trip(delta)
        "BuyPotionForNextTrip":
            _state_buy_potion_for_next_trip()
        "RestockedPotion", "SkipRestockNoStock", "SkipRestockNoGold", "RestockAlreadyHasPotion", "SkipRestockFailed":
            _state_restock_result(delta)
        "GoToExitForNextTrip":
            _state_go_to_exit_for_next_trip()
        "MaxTripsReached":
            pass
        _:
            pass

func start_town_routine(new_general_store_position: Vector2, new_exit_position: Vector2) -> void:
    general_store_position = new_general_store_position
    exit_position = new_exit_position
    set_state("EnterTown")

func start_return_to_town_routine(new_general_store_position: Vector2, new_inn_position: Vector2, new_exit_position: Vector2) -> void:
    general_store_position = new_general_store_position
    inn_position = new_inn_position
    exit_position = new_exit_position
    set_state("ReturnedToTown")

func set_state(new_state: String) -> void:
    current_state = new_state

    if adventurer != null and adventurer.has_method("set_state"):
        adventurer.set_state(current_state)

    match current_state:
        "GoToGeneralStore":
            if adventurer != null:
                adventurer.set_move_target(general_store_position)
        "WaitForGeneralStoreCapacity":
            wait_timer = capacity_retry_wait_seconds
            if adventurer != null:
                _move_to_queue_slot("general_store")
                adventurer.set_purchase_message("General Store full. Queueing.")
        "BuySmallPotion":
            if adventurer != null:
                adventurer.clear_move_target()
        "BoughtPotion", "SkipPurchaseNoStock", "SkipPurchaseNoGold", "SkipPurchaseAlreadyHasPotion", "SkipPurchaseFailed":
            wait_timer = _get_building_service_time("general_store", purchase_result_wait_seconds)
            if adventurer != null:
                adventurer.clear_move_target()
        "GoToExit":
            if adventurer != null:
                adventurer.set_move_target(exit_position)
        "LeavingTown":
            wait_timer = leaving_town_wait_seconds
            if adventurer != null:
                adventurer.clear_move_target()
        "GoToGeneralStoreToSell":
            if adventurer != null:
                adventurer.set_move_target(general_store_position)
        "WaitForGeneralStoreSellCapacity":
            wait_timer = capacity_retry_wait_seconds
            if adventurer != null:
                _move_to_queue_slot("general_store")
                adventurer.set_purchase_message("Store full. Queueing to sell.")
        "SellSlimeGel":
            if adventurer != null:
                adventurer.clear_move_target()
        "SoldLoot", "NoLootToSell", "SaleBlockedMaterialBuyingOff":
            wait_timer = _get_building_service_time("general_store", sell_result_wait_seconds)
            if adventurer != null:
                adventurer.clear_move_target()
        "CheckRecoveryNeed":
            if adventurer != null:
                adventurer.clear_move_target()
        "GoToInn":
            if adventurer != null:
                adventurer.set_move_target(inn_position)
        "WaitForInnCapacity":
            wait_timer = capacity_retry_wait_seconds
            if adventurer != null:
                _move_to_queue_slot("inn")
                adventurer.set_purchase_message("Inn full. Queueing.")
        "RestAtInn":
            wait_timer = _get_building_service_time("inn", inn_rest_seconds)
            if adventurer != null:
                adventurer.clear_move_target()
        "RestedAtInn", "SkipInnRest":
            wait_timer = inn_result_wait_seconds
            if adventurer != null:
                adventurer.clear_move_target()
        "GoToInnForNight":
            if adventurer != null:
                adventurer.set_purchase_message("Night. Going to Inn.")
                adventurer.set_move_target(inn_position)
        "WaitForNightInnCapacity":
            wait_timer = capacity_retry_wait_seconds
            if adventurer != null:
                _move_to_queue_slot("inn")
                adventurer.set_purchase_message("Inn full. Queueing for bed.")
        "SleepAtInn":
            wait_timer = night_sleep_seconds
            if adventurer != null:
                adventurer.clear_move_target()
        "SleptAtInn":
            wait_timer = inn_result_wait_seconds
            if adventurer != null:
                adventurer.clear_move_target()
        "PrepareNextTrip":
            wait_timer = prepare_next_trip_wait_seconds
            if adventurer != null:
                adventurer.clear_move_target()
        "BuyPotionForNextTrip":
            if adventurer != null:
                adventurer.clear_move_target()
        "RestockedPotion", "SkipRestockNoStock", "SkipRestockNoGold", "RestockAlreadyHasPotion", "SkipRestockFailed":
            wait_timer = restock_result_wait_seconds
            if adventurer != null:
                adventurer.clear_move_target()
        "GoToExitForNextTrip":
            if adventurer != null:
                adventurer.set_move_target(exit_position)
        "MaxTripsReached":
            if adventurer != null:
                adventurer.clear_move_target()
                adventurer.set_purchase_message("Max prototype trips reached")
        _:
            pass

func get_state() -> String:
    return current_state


func update_town_route_positions(new_general_store_position: Vector2, new_inn_position: Vector2, new_exit_position: Vector2) -> void:
    general_store_position = new_general_store_position
    inn_position = new_inn_position
    exit_position = new_exit_position

    if adventurer == null:
        return

    match current_state:
        "GoToGeneralStore", "GoToGeneralStoreToSell":
            adventurer.set_move_target(general_store_position)
        "WaitForGeneralStoreCapacity", "WaitForGeneralStoreSellCapacity":
            _move_to_queue_slot("general_store")
        "GoToInn", "GoToInnForNight":
            adventurer.set_move_target(inn_position)
        "WaitForInnCapacity", "WaitForNightInnCapacity":
            _move_to_queue_slot("inn")
        "GoToExit", "GoToExitForNextTrip":
            adventurer.set_move_target(exit_position)
        _:
            pass


func _get_town_node() -> Node:
    if adventurer == null:
        return null

    var container := adventurer.get_parent()
    if container == null:
        return null

    return container.get_parent()



func _get_building_service_time(building_type: String, fallback_seconds: float) -> float:
    var town_node := _get_town_node()
    if town_node == null or not town_node.has_method("get_service_seconds_for_adventurer"):
        return fallback_seconds

    return town_node.get_service_seconds_for_adventurer(building_type, adventurer, fallback_seconds)

func _move_to_queue_slot(building_type: String) -> void:
    if adventurer == null:
        return

    var town_node := _get_town_node()
    if town_node == null or not town_node.has_method("request_building_queue_slot"):
        adventurer.clear_move_target()
        return

    var queue_position: Vector2 = town_node.request_building_queue_slot(building_type, adventurer)
    adventurer.set_move_target(queue_position)

func _request_building_capacity(building_type: String) -> bool:
    var town_node := _get_town_node()
    if town_node == null or not town_node.has_method("request_building_capacity"):
        return true

    return town_node.request_building_capacity(building_type, adventurer)

func _release_building_capacity(building_type: String) -> void:
    var town_node := _get_town_node()
    if town_node == null or not town_node.has_method("release_building_capacity"):
        return

    town_node.release_building_capacity(building_type, adventurer)

func _should_interrupt_for_night_sleep() -> bool:
    if adventurer == null:
        return false
    if not adventurer.has_method("should_seek_night_sleep"):
        return false
    if not adventurer.should_seek_night_sleep():
        return false

    return current_state in [
        "Idle",
        "MaxTripsReached",
        "PrepareNextTrip",
        "SkipInnRest",
        "RestedAtInn"
    ]

func _state_enter_town() -> void:
    set_state("GoToGeneralStore")

func _state_go_to_general_store() -> void:
    if adventurer != null and not adventurer.has_target and adventurer.has_reached_target():
        if _request_building_capacity("general_store"):
            set_state("BuySmallPotion")
        else:
            set_state("WaitForGeneralStoreCapacity")

func _state_wait_for_general_store_capacity(delta: float) -> void:
    wait_timer -= delta
    if adventurer != null and adventurer.has_target and not adventurer.has_reached_target():
        return

    if wait_timer > 0.0:
        return

    if _request_building_capacity("general_store"):
        set_state("BuySmallPotion")
    else:
        set_state("WaitForGeneralStoreCapacity")

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
        _release_building_capacity("general_store")
        set_state("GoToExit")

func _state_go_to_exit() -> void:
    if adventurer != null and not adventurer.has_target and adventurer.has_reached_target():
        set_state("LeavingTown")

func _state_leaving_town(delta: float) -> void:
    wait_timer -= delta
    if wait_timer <= 0.0 and adventurer != null and adventurer.has_method("enter_world_travel"):
        adventurer.enter_world_travel()

func _state_returned_to_town() -> void:
    set_state("GoToGeneralStoreToSell")

func _state_go_to_general_store_to_sell() -> void:
    if adventurer != null and not adventurer.has_target and adventurer.has_reached_target():
        if _request_building_capacity("general_store"):
            set_state("SellSlimeGel")
        else:
            set_state("WaitForGeneralStoreSellCapacity")

func _state_wait_for_general_store_sell_capacity(delta: float) -> void:
    wait_timer -= delta
    if adventurer != null and adventurer.has_target and not adventurer.has_reached_target():
        return

    if wait_timer > 0.0:
        return

    if _request_building_capacity("general_store"):
        set_state("SellSlimeGel")
    else:
        set_state("WaitForGeneralStoreSellCapacity")

func _state_sell_slime_gel() -> void:
    if adventurer == null or not adventurer.has_method("try_sell_slime_gel"):
        set_state("NoLootToSell")
        return
    var result := adventurer.try_sell_slime_gel()
    match result:
        "sold":
            set_state("SoldLoot")
        "buying_disabled":
            set_state("SaleBlockedMaterialBuyingOff")
        _:
            set_state("NoLootToSell")

func _state_sold_loot(delta: float) -> void:
    wait_timer -= delta
    if wait_timer <= 0.0:
        _release_building_capacity("general_store")
        set_state("CheckRecoveryNeed")

func _state_no_loot_to_sell(delta: float) -> void:
    wait_timer -= delta
    if wait_timer <= 0.0:
        _release_building_capacity("general_store")
        set_state("CheckRecoveryNeed")

func _state_sale_blocked(delta: float) -> void:
    wait_timer -= delta
    if wait_timer <= 0.0:
        _release_building_capacity("general_store")
        set_state("CheckRecoveryNeed")

func _state_check_recovery_need() -> void:
    if adventurer == null:
        return
    if adventurer.has_method("needs_inn_rest") and adventurer.needs_inn_rest():
        if adventurer.has_method("is_injured") and adventurer.is_injured():
            adventurer.set_purchase_message("Badly hurt. Going to Inn.")
        else:
            adventurer.set_purchase_message("Exhausted. Going to Inn.")
        set_state("GoToInn")
        return
    if adventurer.has_method("should_seek_night_sleep") and adventurer.should_seek_night_sleep():
        set_state("GoToInnForNight")
        return
    adventurer.set_purchase_message("No Inn rest needed.")
    set_state("SkipInnRest")

func _state_go_to_inn() -> void:
    if adventurer != null and not adventurer.has_target and adventurer.has_reached_target():
        if _request_building_capacity("inn"):
            set_state("RestAtInn")
        else:
            set_state("WaitForInnCapacity")

func _state_wait_for_inn_capacity(delta: float) -> void:
    wait_timer -= delta
    if adventurer != null and adventurer.has_target and not adventurer.has_reached_target():
        return

    if wait_timer > 0.0:
        return

    if _request_building_capacity("inn"):
        set_state("RestAtInn")
    else:
        set_state("WaitForInnCapacity")

func _state_rest_at_inn(delta: float) -> void:
    wait_timer -= delta
    if wait_timer <= 0.0:
        if adventurer != null and adventurer.has_method("rest_at_inn"):
            adventurer.rest_at_inn()
        _release_building_capacity("inn")
        set_state("RestedAtInn")

func _state_inn_result(delta: float) -> void:
    wait_timer -= delta
    if wait_timer <= 0.0:
        set_state("PrepareNextTrip")

func _state_go_to_inn_for_night() -> void:
    if adventurer != null and not adventurer.has_target and adventurer.has_reached_target():
        if _request_building_capacity("inn"):
            set_state("SleepAtInn")
        else:
            set_state("WaitForNightInnCapacity")

func _state_wait_for_night_inn_capacity(delta: float) -> void:
    wait_timer -= delta
    if adventurer != null and adventurer.has_target and not adventurer.has_reached_target():
        return

    if wait_timer > 0.0:
        return

    if _request_building_capacity("inn"):
        set_state("SleepAtInn")
    else:
        set_state("WaitForNightInnCapacity")

func _state_sleep_at_inn(delta: float) -> void:
    wait_timer -= delta
    if wait_timer <= 0.0:
        if adventurer != null and adventurer.has_method("sleep_at_inn_for_night"):
            adventurer.sleep_at_inn_for_night()
        set_state("SleptAtInn")

func _state_slept_at_inn(delta: float) -> void:
    wait_timer -= delta
    if wait_timer > 0.0:
        return
    if GameClock.get_phase_name() == "Night":
        if adventurer != null and adventurer.has_method("set_purchase_message"):
            adventurer.set_purchase_message("Sleeping until Day")
        return
    _release_building_capacity("inn")
    set_state("PrepareNextTrip")

func _state_prepare_next_trip(delta: float) -> void:
    wait_timer -= delta
    if wait_timer > 0.0 or adventurer == null:
        return
    if adventurer.has_method("should_seek_night_sleep") and adventurer.should_seek_night_sleep():
        set_state("GoToInnForNight")
        return
    if adventurer.has_method("should_continue_adventuring") and not adventurer.should_continue_adventuring():
        set_state("MaxTripsReached")
        return
    if adventurer.has_method("needs_small_potion") and adventurer.needs_small_potion():
        set_state("BuyPotionForNextTrip")
    else:
        adventurer.set_purchase_message("Potion ready. Leaving again.")
        set_state("GoToExitForNextTrip")

func _state_buy_potion_for_next_trip() -> void:
    if adventurer == null or not adventurer.has_method("try_buy_small_potion"):
        set_state("SkipRestockFailed")
        return
    var result := adventurer.try_buy_small_potion()
    match result:
        "bought":
            set_state("RestockedPotion")
        "no_stock":
            set_state("SkipRestockNoStock")
        "no_gold":
            set_state("SkipRestockNoGold")
        "already_has_potion":
            set_state("RestockAlreadyHasPotion")
        _:
            set_state("SkipRestockFailed")

func _state_restock_result(delta: float) -> void:
    wait_timer -= delta
    if wait_timer <= 0.0:
        set_state("GoToExitForNextTrip")

func _state_go_to_exit_for_next_trip() -> void:
    if adventurer != null and not adventurer.has_target and adventurer.has_reached_target():
        set_state("LeavingTown")
