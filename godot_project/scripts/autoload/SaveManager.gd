extends Node

signal save_completed(save_type: String, success: bool)
signal load_completed(save_type: String, success: bool)

const BUILDING_LAYOUT_SAVE_PATH := "user://placed_buildings.json"
const CORE_STATE_SAVE_PATH := "user://core_state.json"
const ECONOMY_HISTORY_SAVE_PATH := "user://economy_history.json"
const ADVENTURER_ROSTER_SAVE_PATH := "user://adventurer_roster.json"
const WORLD_STATE_SAVE_PATH := "user://world_state.json"

const FULL_SAVE_SLOT_ID := "slot_1"
const AUTOSAVE_SLOT_ID := "autosave_1"
const SAVE_SLOT_COUNT := 3
const SAVE_SLOT_IDS := ["slot_1", "slot_2", "slot_3"]

const SAVE_SLOT_METADATA_PATH := "user://save_slots_metadata.json"
const SAVE_INDEX_PATH := "user://save_index.json"

const SAVE_MANAGER_VERSION := 2

var last_save_message: String = "No save has been run yet."
var last_load_message: String = "No load has been run yet."
var last_full_save_success: bool = false
var last_full_load_success: bool = false

var active_slot_id: String = FULL_SAVE_SLOT_ID
var active_slot_number: int = 1
var save_slot_metadata: Dictionary = {}

var overwrite_confirmation_armed: bool = false
var clear_confirmation_armed: bool = false
var slot_warning_message: String = "Overwrite and Clear Slot require confirmation."

func _ready() -> void:
    load_save_slot_metadata(false)
    _ensure_active_slot_metadata()
    _sync_active_slot_metadata_from_files(false)

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

func set_active_slot(slot_number: int) -> bool:
    var requested_slot_number: int = clampi(slot_number, 1, SAVE_SLOT_COUNT)
    var requested_slot_id: String = _get_slot_id_from_number(requested_slot_number)

    if save_slot_metadata.is_empty():
        save_slot_metadata = _create_default_slot_metadata()

    if not save_slot_metadata.has("slots") or not save_slot_metadata.get("slots") is Dictionary:
        save_slot_metadata["slots"] = {}

    var slots: Dictionary = save_slot_metadata.get("slots", {})
    if not slots.has(requested_slot_id):
        slots[requested_slot_id] = _create_empty_slot_metadata(requested_slot_id)

    active_slot_number = requested_slot_number
    active_slot_id = requested_slot_id

    save_slot_metadata["active_slot_id"] = active_slot_id
    save_slot_metadata["slots"] = slots

    overwrite_confirmation_armed = false
    clear_confirmation_armed = false
    slot_warning_message = "Active slot changed to Slot %d." % active_slot_number

    _apply_active_slot_metadata_to_session_fields()
    _sync_active_slot_metadata_from_files(true)
    save_save_slot_metadata(false)
    return true

func get_active_slot_number() -> int:
    return active_slot_number

func get_active_slot_id() -> String:
    return active_slot_id

func _get_slot_id_from_number(slot_number: int) -> String:
    var safe_number: int = clampi(slot_number, 1, SAVE_SLOT_COUNT)
    return "slot_%d" % safe_number

func _get_slot_number_from_id(slot_id: String) -> int:
    var parts: PackedStringArray = slot_id.split("_")
    if parts.size() < 2:
        return 1

    return clampi(int(parts[1]), 1, SAVE_SLOT_COUNT)

func _get_slot_path(category: String, slot_id: String = "") -> String:
    var resolved_slot_id: String = active_slot_id if slot_id == "" else slot_id
    var prefix: String = "user://%s" % resolved_slot_id

    match category:
        "buildings":
            return "%s_building_layout.json" % prefix
        "core_state":
            return "%s_core_state.json" % prefix
        "economy":
            return "%s_economy_history.json" % prefix
        "adventurers":
            return "%s_adventurer_roster.json" % prefix
        "world":
            return "%s_world_state.json" % prefix
        _:
            return "%s_unknown.json" % prefix

func _get_slot_paths_for(slot_id: String) -> Dictionary:
    return {
        "core_state": _get_slot_path("core_state", slot_id),
        "buildings": _get_slot_path("buildings", slot_id),
        "economy": _get_slot_path("economy", slot_id),
        "adventurers": _get_slot_path("adventurers", slot_id),
        "world": _get_slot_path("world", slot_id)
    }

func load_save_slot_metadata(show_warning: bool = true) -> bool:
    var data: Dictionary = load_json_file(SAVE_SLOT_METADATA_PATH, show_warning)
    if data.is_empty():
        save_slot_metadata = _create_default_slot_metadata()
        save_save_slot_metadata(false)
        return false

    save_slot_metadata = data
    _ensure_active_slot_metadata()
    _apply_active_slot_metadata_to_session_fields()
    return true

func save_save_slot_metadata(show_warning: bool = true) -> bool:
    _ensure_active_slot_metadata()
    return save_json_file(SAVE_SLOT_METADATA_PATH, save_slot_metadata, show_warning)

func _create_default_slot_metadata() -> Dictionary:
    var slots: Dictionary = {}
    for slot_number in range(1, SAVE_SLOT_COUNT + 1):
        var slot_id: String = _get_slot_id_from_number(slot_number)
        slots[slot_id] = _create_empty_slot_metadata(slot_id)

    slots[AUTOSAVE_SLOT_ID] = _create_autosave_slot_metadata()

    return {
        "version": SAVE_MANAGER_VERSION,
        "active_slot_id": active_slot_id,
        "autosave_slot_id": AUTOSAVE_SLOT_ID,
        "slots": slots
    }

func _create_empty_slot_metadata(slot_id: String) -> Dictionary:
    var slot_number: int = _get_slot_number_from_id(slot_id)
    return {
        "slot_id": slot_id,
        "slot_number": slot_number,
        "label": "Slot %d - Manual Snapshot Prototype" % slot_number,
        "is_occupied": false,
        "last_saved_timestamp": "Never saved",
        "last_loaded_timestamp": "Never loaded",
        "last_save_result": "No save has been run for this slot.",
        "last_load_result": "No load has been run for this slot.",
        "overwrite_armed": false,
        "clear_armed": false,
        "warning_message": "Overwrite and Clear Slot require confirmation.",
        "summary": {
            "core_state": false,
            "buildings": false,
            "economy": false,
            "adventurers": false,
            "world": false
        },
        "paths": _get_slot_paths_for(slot_id),
        "future_slots_ready": true
    }

func _create_autosave_slot_metadata() -> Dictionary:
    return {
        "slot_id": AUTOSAVE_SLOT_ID,
        "slot_number": 0,
        "label": "Autosave - Safety Snapshot",
        "is_occupied": false,
        "last_saved_timestamp": "Never autosaved",
        "last_loaded_timestamp": "Autosave loading not exposed yet",
        "last_save_result": "No autosave has been run yet.",
        "last_load_result": "Autosave load is not exposed yet.",
        "last_autosave_reason": "None",
        "overwrite_armed": false,
        "clear_armed": false,
        "warning_message": "Autosave is separate from manual save slots.",
        "summary": {
            "core_state": false,
            "buildings": false,
            "economy": false,
            "adventurers": false,
            "world": false
        },
        "paths": _get_slot_paths_for(AUTOSAVE_SLOT_ID),
        "is_autosave": true
    }

func _ensure_active_slot_metadata() -> void:
    if save_slot_metadata.is_empty():
        save_slot_metadata = _create_default_slot_metadata()

    var metadata_active_slot_id: String = str(save_slot_metadata.get("active_slot_id", active_slot_id))
    if metadata_active_slot_id != active_slot_id:
        active_slot_id = metadata_active_slot_id

    active_slot_number = _get_slot_number_from_id(active_slot_id)
    active_slot_id = _get_slot_id_from_number(active_slot_number)

    if not save_slot_metadata.has("slots") or not save_slot_metadata.get("slots") is Dictionary:
        save_slot_metadata["slots"] = {}

    var slots: Dictionary = save_slot_metadata.get("slots", {})
    for slot_number in range(1, SAVE_SLOT_COUNT + 1):
        var slot_id: String = _get_slot_id_from_number(slot_number)
        if not slots.has(slot_id):
            slots[slot_id] = _create_empty_slot_metadata(slot_id)

    if not slots.has(AUTOSAVE_SLOT_ID):
        slots[AUTOSAVE_SLOT_ID] = _create_autosave_slot_metadata()

    save_slot_metadata["version"] = SAVE_MANAGER_VERSION
    save_slot_metadata["active_slot_id"] = active_slot_id
    save_slot_metadata["autosave_slot_id"] = AUTOSAVE_SLOT_ID
    save_slot_metadata["slots"] = slots

func _get_active_slot_metadata() -> Dictionary:
    return _get_slot_metadata(active_slot_id)

func _get_slot_metadata(slot_id: String) -> Dictionary:
    _ensure_active_slot_metadata()
    var slots: Dictionary = save_slot_metadata.get("slots", {})
    var default_data: Dictionary = _create_autosave_slot_metadata() if slot_id == AUTOSAVE_SLOT_ID else _create_empty_slot_metadata(slot_id)
    return (slots.get(slot_id, default_data) as Dictionary).duplicate(true)

func _set_slot_metadata(slot_id: String, slot_data: Dictionary, save_now: bool = true) -> void:
    _ensure_active_slot_metadata()
    var slots: Dictionary = save_slot_metadata.get("slots", {})
    slots[slot_id] = slot_data
    save_slot_metadata["slots"] = slots

    if save_now:
        save_save_slot_metadata(false)

func _set_active_slot_metadata(slot_data: Dictionary, save_now: bool = true) -> void:
    _ensure_active_slot_metadata()
    var slots: Dictionary = save_slot_metadata.get("slots", {})
    slots[active_slot_id] = slot_data
    save_slot_metadata["active_slot_id"] = active_slot_id
    save_slot_metadata["slots"] = slots

    if save_now:
        save_save_slot_metadata(false)

func _apply_active_slot_metadata_to_session_fields() -> void:
    var slot_data: Dictionary = _get_active_slot_metadata()
    last_save_message = str(slot_data.get("last_save_result", last_save_message))
    last_load_message = str(slot_data.get("last_load_result", last_load_message))
    overwrite_confirmation_armed = bool(slot_data.get("overwrite_armed", false))
    clear_confirmation_armed = bool(slot_data.get("clear_armed", false))
    slot_warning_message = str(slot_data.get("warning_message", slot_warning_message))

func _sync_active_slot_metadata_from_files(save_now: bool = true) -> void:
    var slot_data: Dictionary = _get_active_slot_metadata()
    var summary: Dictionary = _get_manual_slot_file_summary()

    slot_data["summary"] = summary
    slot_data["is_occupied"] = _is_slot_summary_occupied(summary)
    slot_data["paths"] = _get_slot_paths_for(active_slot_id)

    _set_active_slot_metadata(slot_data, save_now)

func _get_manual_slot_file_summary() -> Dictionary:
    return _get_slot_file_summary(active_slot_id)

func _get_slot_file_summary(slot_id: String) -> Dictionary:
    return {
        "core_state": FileAccess.file_exists(_get_slot_path("core_state", slot_id)),
        "buildings": FileAccess.file_exists(_get_slot_path("buildings", slot_id)),
        "economy": FileAccess.file_exists(_get_slot_path("economy", slot_id)),
        "adventurers": FileAccess.file_exists(_get_slot_path("adventurers", slot_id)),
        "world": FileAccess.file_exists(_get_slot_path("world", slot_id))
    }

func _is_slot_summary_occupied(summary: Dictionary) -> bool:
    for key in summary.keys():
        if bool(summary.get(key, false)):
            return true
    return false

func is_active_slot_occupied() -> bool:
    _sync_active_slot_metadata_from_files(false)
    var slot_data: Dictionary = _get_active_slot_metadata()
    return bool(slot_data.get("is_occupied", false))

func _update_active_slot_after_save(success: bool, message: String) -> void:
    var slot_data: Dictionary = _get_active_slot_metadata()
    var summary: Dictionary = _get_manual_slot_file_summary()

    if success:
        slot_data["last_saved_timestamp"] = Time.get_datetime_string_from_system(false, true)

    slot_data["last_save_result"] = message
    slot_data["overwrite_armed"] = overwrite_confirmation_armed
    slot_data["clear_armed"] = clear_confirmation_armed
    slot_data["warning_message"] = slot_warning_message
    slot_data["summary"] = summary
    slot_data["is_occupied"] = _is_slot_summary_occupied(summary)
    _set_active_slot_metadata(slot_data, true)

func _update_active_slot_after_load(success: bool, message: String) -> void:
    var slot_data: Dictionary = _get_active_slot_metadata()
    var summary: Dictionary = _get_manual_slot_file_summary()

    if success:
        slot_data["last_loaded_timestamp"] = Time.get_datetime_string_from_system(false, true)

    slot_data["last_load_result"] = message
    slot_data["overwrite_armed"] = overwrite_confirmation_armed
    slot_data["clear_armed"] = clear_confirmation_armed
    slot_data["warning_message"] = slot_warning_message
    slot_data["summary"] = summary
    slot_data["is_occupied"] = _is_slot_summary_occupied(summary)
    _set_active_slot_metadata(slot_data, true)

func save_building_layout_data(save_data: Dictionary, show_warning: bool = true) -> bool:
    var success: bool = save_json_file(BUILDING_LAYOUT_SAVE_PATH, save_data, show_warning)
    save_completed.emit("building_layout", success)
    _save_index(false)
    return success

func load_building_layout_data(show_warning: bool = true) -> Dictionary:
    var save_data: Dictionary = load_json_file(BUILDING_LAYOUT_SAVE_PATH, show_warning)
    load_completed.emit("building_layout", not save_data.is_empty())
    return save_data

func save_core_state_data(save_data: Dictionary, show_warning: bool = true) -> bool:
    var success: bool = save_json_file(CORE_STATE_SAVE_PATH, save_data, show_warning)
    save_completed.emit("core_state", success)
    _save_index(false)
    return success

func load_core_state_data(show_warning: bool = true) -> Dictionary:
    var save_data: Dictionary = load_json_file(CORE_STATE_SAVE_PATH, show_warning)
    load_completed.emit("core_state", not save_data.is_empty())
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


func autosave_all(town_node: Node = null, reason: String = "safe_event", show_warning: bool = false) -> bool:
    var success: bool = true
    var saved_buildings: bool = false
    var saved_core: bool = false
    var saved_economy: bool = false
    var saved_adventurers: bool = false
    var saved_world: bool = false

    if town_node != null and town_node.has_method("get_building_layout_save_data"):
        var building_data: Dictionary = town_node.get_building_layout_save_data()
        saved_buildings = save_json_file(_get_slot_path("buildings", AUTOSAVE_SLOT_ID), building_data, show_warning)
        success = saved_buildings and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.autosave_all: town node cannot provide building layout snapshot.")

    if get_node_or_null("/root/GameState") != null and GameState.has_method("get_core_state_save_data"):
        var core_data: Dictionary = GameState.get_core_state_save_data()
        saved_core = save_json_file(_get_slot_path("core_state", AUTOSAVE_SLOT_ID), core_data, show_warning)
        success = saved_core and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.autosave_all: GameState cannot provide core state snapshot.")

    if get_node_or_null("/root/GameState") != null and GameState.has_method("get_economy_history_save_data"):
        var economy_data: Dictionary = GameState.get_economy_history_save_data()
        saved_economy = save_json_file(_get_slot_path("economy", AUTOSAVE_SLOT_ID), economy_data, show_warning)
        success = saved_economy and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.autosave_all: GameState cannot provide economy snapshot.")

    if town_node != null and town_node.has_method("get_adventurer_roster_save_data"):
        var adventurer_data: Dictionary = town_node.get_adventurer_roster_save_data()
        saved_adventurers = save_json_file(_get_slot_path("adventurers", AUTOSAVE_SLOT_ID), adventurer_data, show_warning)
        success = saved_adventurers and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.autosave_all: town node cannot provide adventurer roster snapshot.")

    if get_node_or_null("/root/GameState") != null and GameState.has_method("get_world_state_save_data"):
        var world_data: Dictionary = GameState.get_world_state_save_data()
        saved_world = save_json_file(_get_slot_path("world", AUTOSAVE_SLOT_ID), world_data, show_warning)
        success = saved_world and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.autosave_all: GameState cannot provide world state snapshot.")

    var message: String = "Autosave %s | Reason:%s | Core:%s | Buildings:%s | Economy:%s | Adventurers:%s | World:%s" % [
        "OK" if success else "FAILED",
        reason,
        "saved" if saved_core else "missing",
        "saved" if saved_buildings else "missing",
        "saved" if saved_economy else "missing",
        "saved" if saved_adventurers else "missing",
        "saved" if saved_world else "missing"
    ]

    _update_autosave_slot_after_save(success, message, reason)
    _save_index(false)
    save_completed.emit("autosave", success)
    return success

func _update_autosave_slot_after_save(success: bool, message: String, reason: String) -> void:
    var slot_data: Dictionary = _get_slot_metadata(AUTOSAVE_SLOT_ID)
    var summary: Dictionary = _get_slot_file_summary(AUTOSAVE_SLOT_ID)

    if success:
        slot_data["last_saved_timestamp"] = Time.get_datetime_string_from_system(false, true)

    slot_data["last_save_result"] = message
    slot_data["last_autosave_reason"] = reason
    slot_data["summary"] = summary
    slot_data["is_occupied"] = _is_slot_summary_occupied(summary)
    slot_data["paths"] = _get_slot_paths_for(AUTOSAVE_SLOT_ID)
    _set_slot_metadata(AUTOSAVE_SLOT_ID, slot_data, true)

func get_autosave_status_text() -> String:
    var slot_data: Dictionary = _get_slot_metadata(AUTOSAVE_SLOT_ID)
    var summary: Dictionary = _get_slot_file_summary(AUTOSAVE_SLOT_ID)
    var occupied_text: String = "Occupied" if bool(slot_data.get("is_occupied", false)) else "Empty"

    return "AUTOSAVE [%s]\nLast Autosave: %s\nReason: %s\nCore: %s | Buildings: %s\nEconomy: %s | Adventurers: %s | World: %s\nResult: %s" % [
        occupied_text,
        str(slot_data.get("last_saved_timestamp", "Never autosaved")),
        str(slot_data.get("last_autosave_reason", "None")),
        "saved" if bool(summary.get("core_state", false)) else "empty",
        "saved" if bool(summary.get("buildings", false)) else "empty",
        "saved" if bool(summary.get("economy", false)) else "empty",
        "saved" if bool(summary.get("adventurers", false)) else "empty",
        "saved" if bool(summary.get("world", false)) else "empty",
        str(slot_data.get("last_save_result", "No autosave has been run yet."))
    ]

func save_all(town_node: Node = null, show_warning: bool = true) -> bool:
    var success: bool = true
    var saved_buildings: bool = false
    var saved_core: bool = false
    var saved_economy: bool = false
    var saved_adventurers: bool = false
    var saved_world: bool = false

    if is_active_slot_occupied() and not overwrite_confirmation_armed:
        last_full_save_success = false
        last_save_message = "Save All blocked. Slot %d is occupied. Press Arm Overwrite first, then Save All." % active_slot_number
        slot_warning_message = "WARNING: Slot %d already has a save. Press Arm Overwrite, then Save All to overwrite it." % active_slot_number
        save_save_slot_metadata(false)
        save_completed.emit("all", false)
        return false

    var was_overwrite_confirmed: bool = overwrite_confirmation_armed
    overwrite_confirmation_armed = false

    if town_node != null and town_node.has_method("get_building_layout_save_data"):
        var building_data: Dictionary = town_node.get_building_layout_save_data()
        saved_buildings = save_json_file(_get_slot_path("buildings"), building_data, show_warning)
        success = saved_buildings and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.save_all: town node cannot provide building layout snapshot.")

    if get_node_or_null("/root/GameState") != null and GameState.has_method("get_core_state_save_data"):
        var core_data: Dictionary = GameState.get_core_state_save_data()
        saved_core = save_json_file(_get_slot_path("core_state"), core_data, show_warning)
        success = saved_core and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.save_all: GameState cannot provide core state snapshot.")

    if get_node_or_null("/root/GameState") != null and GameState.has_method("get_economy_history_save_data"):
        var economy_data: Dictionary = GameState.get_economy_history_save_data()
        saved_economy = save_json_file(_get_slot_path("economy"), economy_data, show_warning)
        success = saved_economy and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.save_all: GameState cannot provide economy snapshot.")

    if town_node != null and town_node.has_method("get_adventurer_roster_save_data"):
        var adventurer_data: Dictionary = town_node.get_adventurer_roster_save_data()
        saved_adventurers = save_json_file(_get_slot_path("adventurers"), adventurer_data, show_warning)
        success = saved_adventurers and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.save_all: town node cannot provide adventurer roster snapshot.")

    if get_node_or_null("/root/GameState") != null and GameState.has_method("get_world_state_save_data"):
        var world_data: Dictionary = GameState.get_world_state_save_data()
        saved_world = save_json_file(_get_slot_path("world"), world_data, show_warning)
        success = saved_world and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.save_all: GameState cannot provide world state snapshot.")

    success = _save_index(show_warning) and success
    last_full_save_success = success
    last_save_message = "Save All %s | Slot:%d | Overwrite:%s | Core:%s | Buildings:%s | Economy:%s | Adventurers:%s | World:%s" % [
        "OK" if success else "FAILED",
        active_slot_number,
        "confirmed" if was_overwrite_confirmed else "not needed",
        "snapshot saved" if saved_core else "missing",
        "snapshot saved" if saved_buildings else "missing",
        "snapshot saved" if saved_economy else "missing",
        "snapshot saved" if saved_adventurers else "missing",
        "snapshot saved" if saved_world else "missing"
    ]

    slot_warning_message = "Save All completed for Slot %d." % active_slot_number if success else "Save All failed or partial for Slot %d." % active_slot_number
    _update_active_slot_after_save(success, last_save_message)
    save_completed.emit("all", success)
    return success

func load_all(town_node: Node = null, show_warning: bool = true) -> bool:
    var success: bool = true
    var loaded_buildings: bool = false
    var loaded_core: bool = false
    var loaded_economy: bool = false
    var loaded_adventurers: bool = false
    var loaded_world: bool = false

    var core_data: Dictionary = load_json_file(_get_slot_path("core_state"), show_warning)
    if not core_data.is_empty() and get_node_or_null("/root/GameState") != null and GameState.has_method("apply_core_state_save_data"):
        loaded_core = GameState.apply_core_state_save_data(core_data, show_warning)
        success = loaded_core and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.load_all: no manual core snapshot found for active slot.")

    var economy_data: Dictionary = load_json_file(_get_slot_path("economy"), show_warning)
    if not economy_data.is_empty() and get_node_or_null("/root/GameState") != null and GameState.has_method("apply_economy_history_save_data"):
        loaded_economy = GameState.apply_economy_history_save_data(economy_data, show_warning)
        success = loaded_economy and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.load_all: no manual economy snapshot found for active slot.")

    var world_data: Dictionary = load_json_file(_get_slot_path("world"), show_warning)
    if not world_data.is_empty() and get_node_or_null("/root/GameState") != null and GameState.has_method("apply_world_state_save_data"):
        loaded_world = GameState.apply_world_state_save_data(world_data, show_warning)
        success = loaded_world and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.load_all: no manual world state snapshot found for active slot.")

    var building_data: Dictionary = load_json_file(_get_slot_path("buildings"), show_warning)
    if not building_data.is_empty() and town_node != null and town_node.has_method("apply_building_layout_save_data"):
        loaded_buildings = town_node.apply_building_layout_save_data(building_data, false)
        success = loaded_buildings and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.load_all: no manual building snapshot found for active slot.")

    var adventurer_data: Dictionary = load_json_file(_get_slot_path("adventurers"), show_warning)
    if not adventurer_data.is_empty() and town_node != null and town_node.has_method("apply_adventurer_roster_save_data"):
        loaded_adventurers = town_node.apply_adventurer_roster_save_data(adventurer_data, false)
        success = loaded_adventurers and success
    else:
        success = false
        if show_warning:
            push_warning("SaveManager.load_all: no manual adventurer roster snapshot found for active slot.")

    last_full_load_success = success
    last_load_message = "Load All %s | Slot:%d | Core:%s | Buildings:%s | Economy:%s | Adventurers:%s | World:%s" % [
        "OK" if success else "PARTIAL/FAILED",
        active_slot_number,
        "snapshot loaded" if loaded_core else "not found",
        "snapshot loaded" if loaded_buildings else "not found",
        "snapshot loaded" if loaded_economy else "not found",
        "snapshot loaded" if loaded_adventurers else "not found",
        "snapshot loaded" if loaded_world else "not found"
    ]

    slot_warning_message = "Load All completed for Slot %d." % active_slot_number if success else "Load All partial or failed for Slot %d." % active_slot_number
    _update_active_slot_after_load(success, last_load_message)
    load_completed.emit("all", success)
    return success

func get_save_manager_summary() -> String:
    return "SaveManager v%d\nActive Slot: Slot %d (%s)\nAutosave Slot: %s\nManual building snapshot: %s\nManual core snapshot: %s\nManual economy snapshot: %s\nManual adventurer snapshot: %s\nManual world snapshot: %s\nLive building file: %s\nLive economy file: %s\nSave index: %s\nFuture hooks: settings" % [
        SAVE_MANAGER_VERSION,
        active_slot_number,
        active_slot_id,
        AUTOSAVE_SLOT_ID,
        _get_slot_path("buildings"),
        _get_slot_path("core_state"),
        _get_slot_path("economy"),
        _get_slot_path("adventurers"),
        _get_slot_path("world"),
        BUILDING_LAYOUT_SAVE_PATH,
        ECONOMY_HISTORY_SAVE_PATH,
        SAVE_INDEX_PATH
    ]

func get_last_save_status_text() -> String:
    return last_save_message

func get_last_load_status_text() -> String:
    return last_load_message

func get_active_slot_label_text() -> String:
    var slot_data: Dictionary = _get_active_slot_metadata()
    var occupied_text: String = "Occupied" if bool(slot_data.get("is_occupied", false)) else "Empty"
    return "%s [%s]" % [
        str(slot_data.get("label", "Slot %d - Manual Snapshot Prototype" % active_slot_number)),
        occupied_text
    ]

func get_active_slot_timestamp_text() -> String:
    var slot_data: Dictionary = _get_active_slot_metadata()
    return "Last Saved: %s\nLast Loaded: %s" % [
        str(slot_data.get("last_saved_timestamp", "Never saved")),
        str(slot_data.get("last_loaded_timestamp", "Never loaded"))
    ]

func get_active_slot_summary_text() -> String:
    _sync_active_slot_metadata_from_files(false)
    var slot_data: Dictionary = _get_active_slot_metadata()
    var summary: Dictionary = slot_data.get("summary", {})
    return "Slot Contents\nCore State: %s\nBuildings: %s\nEconomy: %s\nAdventurers: %s\nWorld: %s" % [
        "saved" if bool(summary.get("core_state", false)) else "empty",
        "saved" if bool(summary.get("buildings", false)) else "empty",
        "saved" if bool(summary.get("economy", false)) else "empty",
        "saved" if bool(summary.get("adventurers", false)) else "empty",
        "saved" if bool(summary.get("world", false)) else "empty"
    ]

func get_overwrite_confirmation_placeholder_text() -> String:
    if not is_active_slot_occupied():
        return "Overwrite: not required. Slot %d is empty." % active_slot_number

    return "Overwrite Confirmation: %s\n%s" % [
        "ARMED" if overwrite_confirmation_armed else "not armed",
        "Press Save All now to overwrite Slot %d." % active_slot_number if overwrite_confirmation_armed else "Press Arm Overwrite before Save All."
    ]

func request_overwrite_confirmation() -> bool:
    if not is_active_slot_occupied():
        overwrite_confirmation_armed = false
        slot_warning_message = "Slot %d is empty. Save All can write without overwrite confirmation." % active_slot_number
        save_save_slot_metadata(false)
        return false

    overwrite_confirmation_armed = true
    clear_confirmation_armed = false
    slot_warning_message = "Overwrite armed. Press Save All to replace Slot %d. This will overwrite the manual snapshot." % active_slot_number
    save_save_slot_metadata(false)
    return true

func toggle_overwrite_confirmation_placeholder() -> bool:
    return request_overwrite_confirmation()

func get_clear_slot_placeholder_text() -> String:
    return "Clear Slot Confirmation: %s\n%s" % [
        "ARMED" if clear_confirmation_armed else "not armed",
        slot_warning_message
    ]

func request_clear_slot_confirmation() -> String:
    if not is_active_slot_occupied():
        clear_confirmation_armed = false
        slot_warning_message = "Slot %d is already empty. Nothing was deleted." % active_slot_number
        save_save_slot_metadata(false)
        return slot_warning_message

    if not clear_confirmation_armed:
        clear_confirmation_armed = true
        overwrite_confirmation_armed = false
        slot_warning_message = "Clear Slot armed. Press Clear Slot again to permanently delete Slot %d manual snapshot files." % active_slot_number
        save_save_slot_metadata(false)
        return slot_warning_message

    var deleted: bool = clear_active_slot_files()
    clear_confirmation_armed = false
    overwrite_confirmation_armed = false

    if deleted:
        slot_warning_message = "Slot %d cleared. Manual snapshot files were deleted." % active_slot_number
    else:
        slot_warning_message = "Clear Slot attempted, but one or more files could not be deleted."

    save_save_slot_metadata(false)
    return slot_warning_message

func request_clear_slot_placeholder() -> String:
    return request_clear_slot_confirmation()

func clear_active_slot_files() -> bool:
    var success: bool = true
    var files_to_delete: Array[String] = [
        _get_slot_path("buildings"),
        _get_slot_path("core_state"),
        _get_slot_path("economy"),
        _get_slot_path("adventurers"),
        _get_slot_path("world")
    ]

    for file_path in files_to_delete:
        success = _delete_file_if_exists(file_path) and success

    var slot_data: Dictionary = _get_active_slot_metadata()
    slot_data["is_occupied"] = false
    slot_data["last_saved_timestamp"] = "Never saved"
    slot_data["last_loaded_timestamp"] = "Never loaded"
    slot_data["last_save_result"] = "Slot %d cleared." % active_slot_number
    slot_data["last_load_result"] = "Slot %d cleared." % active_slot_number
    slot_data["overwrite_armed"] = false
    slot_data["clear_armed"] = false
    slot_data["warning_message"] = "Slot %d cleared." % active_slot_number
    slot_data["summary"] = {
        "core_state": false,
        "buildings": false,
        "economy": false,
        "adventurers": false,
        "world": false
    }
    slot_data["paths"] = _get_slot_paths_for(active_slot_id)

    last_save_message = "Slot %d cleared." % active_slot_number
    last_load_message = "Slot %d cleared." % active_slot_number

    _set_active_slot_metadata(slot_data, false)
    _save_index(false)
    return success

func _delete_file_if_exists(file_path: String) -> bool:
    if not FileAccess.file_exists(file_path):
        return true

    var error_code: int = DirAccess.remove_absolute(file_path)
    if error_code != OK:
        push_warning("Failed to delete save slot file %s. Error %s." % [file_path, str(error_code)])
        return false

    return true

func _save_index(show_warning: bool = true) -> bool:
    var index_data: Dictionary = {
        "version": SAVE_MANAGER_VERSION,
        "building_layout_path": BUILDING_LAYOUT_SAVE_PATH,
        "core_state_path": CORE_STATE_SAVE_PATH,
        "economy_history_path": ECONOMY_HISTORY_SAVE_PATH,
        "adventurer_roster_path": ADVENTURER_ROSTER_SAVE_PATH,
        "world_state_path": WORLD_STATE_SAVE_PATH,
        "save_slot_metadata_path": SAVE_SLOT_METADATA_PATH,
        "active_slot_id": active_slot_id,
        "active_slot_number": active_slot_number,
        "autosave_slot_id": AUTOSAVE_SLOT_ID,
        "autosave_core_state_path": _get_slot_path("core_state", AUTOSAVE_SLOT_ID),
        "autosave_building_layout_path": _get_slot_path("buildings", AUTOSAVE_SLOT_ID),
        "autosave_economy_history_path": _get_slot_path("economy", AUTOSAVE_SLOT_ID),
        "autosave_adventurer_roster_path": _get_slot_path("adventurers", AUTOSAVE_SLOT_ID),
        "autosave_world_state_path": _get_slot_path("world", AUTOSAVE_SLOT_ID),
        "active_slot_label": get_active_slot_label_text(),
        "slot_is_occupied": bool(_get_active_slot_metadata().get("is_occupied", false)),
        "manual_building_layout_path": _get_slot_path("buildings"),
        "manual_core_state_path": _get_slot_path("core_state"),
        "manual_economy_history_path": _get_slot_path("economy"),
        "manual_adventurer_roster_path": _get_slot_path("adventurers"),
        "manual_world_state_path": _get_slot_path("world"),
        "future_multi_slot_ready": true,
        "implemented_hooks": [
            "buildings",
            "core_state",
            "economy_history",
            "active_town_adventurers",
            "world_state"
        ],
        "future_hooks": [
            "settings"
        ]
    }

    return save_json_file(SAVE_INDEX_PATH, index_data, show_warning)
