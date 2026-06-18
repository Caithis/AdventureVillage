extends Node

signal save_completed(save_type: String, success: bool)
signal load_completed(save_type: String, success: bool)

const BUILDING_LAYOUT_SAVE_PATH := "user://placed_buildings.json"
const ECONOMY_HISTORY_SAVE_PATH := "user://economy_history.json"
const ADVENTURER_ROSTER_SAVE_PATH := "user://adventurer_roster.json"
const WORLD_STATE_SAVE_PATH := "user://world_state.json"
const FULL_SAVE_SLOT_ID := "slot_1"
const FULL_SAVE_BUILDING_LAYOUT_PATH := "user://slot_1_building_layout.json"
const FULL_SAVE_ECONOMY_HISTORY_PATH := "user://slot_1_economy_history.json"
const FULL_SAVE_ADVENTURER_ROSTER_PATH := "user://slot_1_adventurer_roster.json"
const FULL_SAVE_WORLD_STATE_PATH := "user://slot_1_world_state.json"
const SAVE_INDEX_PATH := "user://save_index.json"

const SAVE_MANAGER_VERSION := 1

var last_save_message: String = "No save has been run yet."
var last_load_message: String = "No load has been run yet."
var last_full_save_success: bool = false
var last_full_load_success: bool = false

func save_json_file(file_path: String, save_data: Dictionary, show_warning: bool = true) -> bool:
    var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
    if file == null:
        last_save_message = "Save failed for %s. File error %s." % [file_path, str(FileAccess.get_open_error())]
        if show_warning:
            push_warning(last_save_message)
        return false

    file.store_string(JSON.stringify(save_data, "\t"))
    file.close()
    last_save_message = "Saved %s." % file_path
    return true

func load_json_file(file_path: String, show_warning: bool = true) -> Dictionary:
    if not FileAccess.file_exists(file_path):
        last_load_message = "No save file found at %s." % file_path
        return {}

    var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        last_load_message = "Load failed for %s. File error %s." % [file_path, str(FileAccess.get_open_error())]
        if show_warning:
            push_warning(last_load_message)
        return {}

    var file_text: String = file.get_as_text()
    file.close()

    var parsed: Variant = JSON.parse_string(file_text)
    if not parsed is Dictionary:
        last_load_message = "Save file is invalid at %s." % file_path
        if show_warning:
            push_warning(last_load_message)
        return {}

    last_load_message = "Loaded %s." % file_path
    return parsed as Dictionary

func save_building_layout_data(save_data: Dictionary, show_warning: bool = true) -> bool:
    var success: bool = save_json_file(BUILDING_LAYOUT_SAVE_PATH, save_data, show_warning)
    save_completed.emit("building_layout", success)
    _save_index(false)
    return success

func load_building_layout_data(show_warning: bool = true) -> Dictionary:
    var save_data: Dictionary = load_json_file(BUILDING_LAYOUT_SAVE_PATH, show_warning)
    load_completed.emit("building_layout", not save_data.is_empty())
    return save_data

func save_economy_history_data(save_data: Dictionary, show_warning: bool = true) -> bool:
    var success: bool = save_json_file(ECONOMY_HISTORY_SAVE_PATH, save_data, show_warning)
    save_completed.emit("economy_history", success)
    _save_index(false)
    return success

func load_economy_history_data(show_warning: bool = true) -> Dictionary:
    var save_data: Dictionary = load_json_file(ECONOMY_HISTORY_SAVE_PATH, show_warning)
    load_completed.emit("economy_history", not save_data.is_empty())
    return save_data

func save_adventurer_roster_data(save_data: Dictionary, show_warning: bool = true) -> bool:
    var success: bool = save_json_file(ADVENTURER_ROSTER_SAVE_PATH, save_data, show_warning)
    save_completed.emit("adventurer_roster", success)
    _save_index(false)
    return success

func load_adventurer_roster_data(show_warning: bool = true) -> Dictionary:
    var save_data: Dictionary = load_json_file(ADVENTURER_ROSTER_SAVE_PATH, show_warning)
    load_completed.emit("adventurer_roster", not save_data.is_empty())
    return save_data

func save_world_state_data(save_data: Dictionary, show_warning: bool = true) -> bool:
    var success: bool = save_json_file(WORLD_STATE_SAVE_PATH, save_data, show_warning)
    save_completed.emit("world_state", success)
    _save_index(false)
    return success

func load_world_state_data(show_warning: bool = true) -> Dictionary:
    var save_data: Dictionary = load_json_file(WORLD_STATE_SAVE_PATH, show_warning)
    load_completed.emit("world_state", not save_data.is_empty())
    return save_data

func save_all(town_node: Node = null, show_warning: bool = true) -> bool:
    var success: bool = true
    var saved_buildings: bool = false
    var saved_economy: bool = false
    var saved_adventurers: bool = false
    var saved_world: bool = false

    if town_node != null and town_node.has_method("get_building_layout_save_data"):
        var building_data: Dictionary = town_node.get_building_layout_save_data()
        saved_buildings = save_json_file(FULL_SAVE_BUILDING_LAYOUT_PATH, building_data, show_warning)
        success = saved_buildings and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.save_all: town node cannot provide building layout snapshot.")

    if get_node_or_null("/root/GameState") != null and GameState.has_method("get_economy_history_save_data"):
        var economy_data: Dictionary = GameState.get_economy_history_save_data()
        saved_economy = save_json_file(FULL_SAVE_ECONOMY_HISTORY_PATH, economy_data, show_warning)
        success = saved_economy and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.save_all: GameState cannot provide economy snapshot.")

    if town_node != null and town_node.has_method("get_adventurer_roster_save_data"):
        var adventurer_data: Dictionary = town_node.get_adventurer_roster_save_data()
        saved_adventurers = save_json_file(FULL_SAVE_ADVENTURER_ROSTER_PATH, adventurer_data, show_warning)
        success = saved_adventurers and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.save_all: town node cannot provide adventurer roster snapshot.")

    if get_node_or_null("/root/GameState") != null and GameState.has_method("get_world_state_save_data"):
        var world_data: Dictionary = GameState.get_world_state_save_data()
        saved_world = save_json_file(FULL_SAVE_WORLD_STATE_PATH, world_data, show_warning)
        success = saved_world and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.save_all: GameState cannot provide world state snapshot.")

    success = _save_index(show_warning) and success
    last_full_save_success = success
    last_save_message = "Save All %s | Slot:%s | Buildings:%s | Economy:%s | Adventurers:%s | World:%s" % [
        "OK" if success else "FAILED",
        FULL_SAVE_SLOT_ID,
        "snapshot saved" if saved_buildings else "missing",
        "snapshot saved" if saved_economy else "missing",
        "snapshot saved" if saved_adventurers else "missing",
        "snapshot saved" if saved_world else "missing"
    ]
    save_completed.emit("all", success)
    return success

func load_all(town_node: Node = null, show_warning: bool = true) -> bool:
    var success: bool = true
    var loaded_buildings: bool = false
    var loaded_economy: bool = false
    var loaded_adventurers: bool = false
    var loaded_world: bool = false

    var economy_data: Dictionary = load_json_file(FULL_SAVE_ECONOMY_HISTORY_PATH, show_warning)
    if not economy_data.is_empty() and get_node_or_null("/root/GameState") != null and GameState.has_method("apply_economy_history_save_data"):
        loaded_economy = GameState.apply_economy_history_save_data(economy_data, show_warning)
        success = loaded_economy and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.load_all: no manual economy snapshot found for Slot 1.")

    var world_data: Dictionary = load_json_file(FULL_SAVE_WORLD_STATE_PATH, show_warning)
    if not world_data.is_empty() and get_node_or_null("/root/GameState") != null and GameState.has_method("apply_world_state_save_data"):
        loaded_world = GameState.apply_world_state_save_data(world_data, show_warning)
        success = loaded_world and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.load_all: no manual world state snapshot found for Slot 1.")

    var building_data: Dictionary = load_json_file(FULL_SAVE_BUILDING_LAYOUT_PATH, show_warning)
    if not building_data.is_empty() and town_node != null and town_node.has_method("apply_building_layout_save_data"):
        loaded_buildings = town_node.apply_building_layout_save_data(building_data, false)
        success = loaded_buildings and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.load_all: no manual building snapshot found for Slot 1.")

    var adventurer_data: Dictionary = load_json_file(FULL_SAVE_ADVENTURER_ROSTER_PATH, show_warning)
    if not adventurer_data.is_empty() and town_node != null and town_node.has_method("apply_adventurer_roster_save_data"):
        loaded_adventurers = town_node.apply_adventurer_roster_save_data(adventurer_data, false)
        success = loaded_adventurers and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.load_all: no manual adventurer roster snapshot found for Slot 1.")

    last_full_load_success = success
    last_load_message = "Load All %s | Slot:%s | Buildings:%s | Economy:%s | Adventurers:%s | World:%s" % [
        "OK" if success else "PARTIAL/FAILED",
        FULL_SAVE_SLOT_ID,
        "snapshot loaded" if loaded_buildings else "not found",
        "snapshot loaded" if loaded_economy else "not found",
        "snapshot loaded" if loaded_adventurers else "not found",
        "snapshot loaded" if loaded_world else "not found"
    ]
    load_completed.emit("all", success)
    return success

func get_save_manager_summary() -> String:
    return "SaveManager v%d\nActive Slot: Slot 1 (Manual Snapshot)\nManual building snapshot: %s\nManual economy snapshot: %s\nManual adventurer snapshot: %s\nManual world snapshot: %s\nLive building file: %s\nLive economy file: %s\nSave index: %s\nFuture hooks: adventurers, world state, settings" % [
        SAVE_MANAGER_VERSION,
        FULL_SAVE_BUILDING_LAYOUT_PATH,
        FULL_SAVE_ECONOMY_HISTORY_PATH,
        FULL_SAVE_ADVENTURER_ROSTER_PATH,
        FULL_SAVE_WORLD_STATE_PATH,
        BUILDING_LAYOUT_SAVE_PATH,
        ECONOMY_HISTORY_SAVE_PATH,
        SAVE_INDEX_PATH
    ]

func get_last_save_status_text() -> String:
    return last_save_message

func get_last_load_status_text() -> String:
    return last_load_message

func _save_index(show_warning: bool = true) -> bool:
    var index_data: Dictionary = {
        "version": SAVE_MANAGER_VERSION,
        "building_layout_path": BUILDING_LAYOUT_SAVE_PATH,
        "economy_history_path": ECONOMY_HISTORY_SAVE_PATH,
        "manual_slot_id": FULL_SAVE_SLOT_ID,
        "manual_building_layout_path": FULL_SAVE_BUILDING_LAYOUT_PATH,
        "manual_economy_history_path": FULL_SAVE_ECONOMY_HISTORY_PATH,
        "manual_adventurer_roster_path": FULL_SAVE_ADVENTURER_ROSTER_PATH,
        "adventurer_roster_path": ADVENTURER_ROSTER_SAVE_PATH,
        "manual_world_state_path": FULL_SAVE_WORLD_STATE_PATH,
        "world_state_path": WORLD_STATE_SAVE_PATH,
        "future_hooks": [
            "settings"
        ],
        "implemented_hooks": [
            "buildings",
            "economy_history",
            "active_town_adventurers",
            "world_state"
        ]
    }

    return save_json_file(SAVE_INDEX_PATH, index_data, show_warning)
