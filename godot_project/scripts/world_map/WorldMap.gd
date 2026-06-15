extends Node2D

const FLOATING_TEXT_SCENE: PackedScene = preload("res://scenes/ui/FloatingText.tscn")

@onready var world_travelers_container: Node2D = $WorldTravelers
@onready var slimes_container: Node2D = $Slimes

var traveler_markers: Dictionary = {}
var slime_markers: Dictionary = {}
var last_traveler_event_logs: Dictionary = {}
var last_slime_event_logs: Dictionary = {}

func _ready() -> void:
	print("World Map scene loaded.")
	GameState.state_changed.connect(_refresh_world_state)
	_refresh_world_state()

func _process(_delta: float) -> void:
	_update_marker_positions_and_labels()
	_update_slime_positions_and_labels()

func _exit_tree() -> void:
	if GameState.state_changed.is_connected(_refresh_world_state):
		GameState.state_changed.disconnect(_refresh_world_state)

func _refresh_world_state() -> void:
	_refresh_world_travelers()
	_refresh_slimes()

func _refresh_world_travelers() -> void:
	var active_ids: Array[int] = []

	for index in range(GameState.get_world_travelers().size()):
		var traveler: Dictionary = GameState.get_world_travelers()[index]
		var traveler_id: int = int(traveler.get("id", index))
		active_ids.append(traveler_id)

		if not traveler_markers.has(traveler_id):
			var marker: Node2D = _create_traveler_marker(traveler)
			world_travelers_container.add_child(marker)
			traveler_markers[traveler_id] = marker

	var ids_to_remove: Array[int] = []
	for traveler_id in traveler_markers.keys():
		if not active_ids.has(int(traveler_id)):
			ids_to_remove.append(int(traveler_id))

	for traveler_id in ids_to_remove:
		var marker_to_remove: Node2D = traveler_markers[traveler_id]
		if is_instance_valid(marker_to_remove):
			marker_to_remove.queue_free()
		traveler_markers.erase(traveler_id)
		last_traveler_event_logs.erase(traveler_id)

	_update_marker_positions_and_labels()

func _refresh_slimes() -> void:
	var active_ids: Array[int] = []

	for index in range(GameState.get_world_slimes().size()):
		var slime: Dictionary = GameState.get_world_slimes()[index]
		var slime_id: int = int(slime.get("id", index))
		active_ids.append(slime_id)

		if not slime_markers.has(slime_id):
			var marker: Node2D = _create_slime_marker(slime)
			slimes_container.add_child(marker)
			slime_markers[slime_id] = marker
			_spawn_floating_text(marker, "Slime Spawn")

	var ids_to_remove: Array[int] = []
	for slime_id in slime_markers.keys():
		if not active_ids.has(int(slime_id)):
			ids_to_remove.append(int(slime_id))

	for slime_id in ids_to_remove:
		var marker_to_remove: Node2D = slime_markers[slime_id]
		if is_instance_valid(marker_to_remove):
			marker_to_remove.queue_free()
		slime_markers.erase(slime_id)
		last_slime_event_logs.erase(slime_id)

	_update_slime_positions_and_labels()

func _update_marker_positions_and_labels() -> void:
	var travelers: Array[Dictionary] = GameState.get_world_travelers()

	for index in range(travelers.size()):
		var traveler: Dictionary = travelers[index]
		var traveler_id: int = int(traveler.get("id", index))

		if not traveler_markers.has(traveler_id):
			continue

		var marker: Node2D = traveler_markers[traveler_id]
		var base_position: Vector2 = traveler.get("world_position", Vector2(642, 430))
		var offset: Vector2 = Vector2((index % 5) * 22, floori(float(index) / 5.0) * 28)
		marker.position = base_position + offset

		var label := marker.get_node_or_null("Label") as Label
		if label != null:
			label.text = _build_traveler_label(traveler)

		_show_world_event_if_needed(traveler, marker)

func _update_slime_positions_and_labels() -> void:
	var slimes: Array[Dictionary] = GameState.get_world_slimes()

	for index in range(slimes.size()):
		var slime: Dictionary = slimes[index]
		var slime_id: int = int(slime.get("id", index))

		if not slime_markers.has(slime_id):
			continue

		var marker: Node2D = slime_markers[slime_id]
		marker.position = slime.get("world_position", Vector2(915, 275))

		var label := marker.get_node_or_null("Label") as Label
		if label != null:
			label.text = _build_slime_label(slime)

		_show_slime_event_if_needed(slime, marker)

func _create_traveler_marker(traveler: Dictionary) -> Node2D:
	var marker := Node2D.new()
	marker.name = "WorldTraveler_%s" % str(traveler.get("id", 0))

	var body := ColorRect.new()
	body.name = "Body"
	body.size = Vector2(16, 16)
	body.position = Vector2(-8, -8)
	body.color = Color(0.75, 0.75, 0.95, 1)
	marker.add_child(body)

	var label := Label.new()
	label.name = "Label"
	label.position = Vector2(-70, -110)
	label.size = Vector2(280, 125)
	label.text = _build_traveler_label(traveler)
	marker.add_child(label)

	return marker

func _create_slime_marker(slime: Dictionary) -> Node2D:
	var marker := Node2D.new()
	marker.name = "Slime_%s" % str(slime.get("id", 0))

	var body := ColorRect.new()
	body.name = "Body"
	body.size = Vector2(14, 14)
	body.position = Vector2(-7, -7)
	body.color = Color(0.35, 0.9, 0.45, 1)
	marker.add_child(body)

	var label := Label.new()
	label.name = "Label"
	label.position = Vector2(-45, 12)
	label.size = Vector2(150, 54)
	label.text = _build_slime_label(slime)
	marker.add_child(label)

	return marker

func _show_world_event_if_needed(traveler: Dictionary, marker: Node2D) -> void:
	var traveler_id: int = int(traveler.get("id", -1))
	if traveler_id < 0:
		return

	var status: String = str(traveler.get("status", ""))
	var log_line: String = str(traveler.get("last_combat_log", ""))
	var floating_event_text: String = str(traveler.get("floating_event_text", ""))
	var damage_taken: int = int(traveler.get("last_damage_taken", 0))
	var damage_dealt: int = int(traveler.get("last_damage_dealt", 0))
	var event_key: String = "%s|%s|%s|%d|%d" % [status, log_line, floating_event_text, damage_taken, damage_dealt]

	if str(last_traveler_event_logs.get(traveler_id, "")) == event_key:
		return

	last_traveler_event_logs[traveler_id] = event_key

	var event_text: String = floating_event_text
	if event_text == "":
		event_text = _get_world_event_text(status, log_line)

	if event_text != "":
		_spawn_floating_text(marker, event_text)

	if damage_taken > 0:
		_spawn_floating_text(marker, "-%d HP" % damage_taken, Vector2(0, -66))

	if damage_dealt > 0 and status == "FightingVisibleSlime":
		_spawn_floating_text(marker, "%d dmg" % damage_dealt, Vector2(0, -90))

func _show_slime_event_if_needed(slime: Dictionary, marker: Node2D) -> void:
	var slime_id: int = int(slime.get("id", -1))
	if slime_id < 0:
		return

	var status: String = str(slime.get("status", ""))
	var log_line: String = str(slime.get("last_event_log", ""))
	var event_key: String = "%s|%s" % [status, log_line]

	if str(last_slime_event_logs.get(slime_id, "")) == event_key:
		return

	last_slime_event_logs[slime_id] = event_key

	if status == "AggroTraveler":
		_spawn_floating_text(marker, "Aggro!")
	elif status == "Engaged":
		_spawn_floating_text(marker, "Engaged")
	elif status == "Defeated":
		_spawn_floating_text(marker, "Slime Defeated")

func _get_world_event_text(status: String, log_line: String) -> String:
	if status == "FightingVisibleSlime":
		return "Combat!"

	if status == "NightQuesting":
		return "Night Quest"

	if status == "SearchingForSlime":
		return "Searching..."

	if status == "SeekingNextSlime":
		return "Hunting..."

	if status == "ReturningLowEnergyAtNight":
		return "Too Tired - Return"

	if status == "ReturningNightRestricted":
		return "Night Quests Off"

	if log_line.contains("Won vs Slime"):
		return "Victory!"

	if log_line.contains("Lost vs Slime"):
		return "Defeated!"

	if log_line.contains("Slime ambush"):
		return "Ambush!"

	if log_line.contains("Day returned"):
		return "Day Returned"

	if log_line.contains("Night danger"):
		return "Night Danger"

	return ""

func _spawn_floating_text(anchor: Node2D, text: String, offset: Vector2 = Vector2(0, -42)) -> void:
	var floating_text := FLOATING_TEXT_SCENE.instantiate()
	add_child(floating_text)
	floating_text.global_position = anchor.global_position + offset

	if floating_text.has_method("setup"):
		floating_text.setup(text)

func _build_traveler_label(traveler: Dictionary) -> String:
	var inventory: Dictionary = traveler.get("inventory", {})
	var sale_message: String = str(traveler.get("sale_message", ""))
	var log_line: String = sale_message
	if log_line == "":
		log_line = str(traveler.get("last_combat_log", ""))

	return "%s\n%s | Gold:%d\nHP %d/%d | E:%d/%d\nP:%d G:%d | T:%d/%d K:%d\n%s" % [
		str(traveler.get("display_name", "Traveler")),
		str(traveler.get("status", "Unknown")),
		int(traveler.get("gold", 0)),
		int(traveler.get("hp", 0)),
		int(traveler.get("max_hp", 0)),
		int(traveler.get("energy", 0)),
		int(traveler.get("max_energy", 0)),
		int(inventory.get("small_potion", 0)),
		int(inventory.get("slime_gel", 0)),
		int(traveler.get("trip_count", 0)),
		int(traveler.get("max_trip_count", 0)),
		int(traveler.get("slime_kills_this_outing", 0)),
		log_line
	]

func _build_slime_label(slime: Dictionary) -> String:
	return "%s Lv.%d\n%s\nHP:%d ATK:%d" % [
		str(slime.get("display_name", "Slime")),
		int(slime.get("level", 1)),
		str(slime.get("status", "Wandering")),
		int(slime.get("max_hp", GameState.get_current_slime_max_hp())),
		int(slime.get("attack", GameState.get_current_slime_attack()))
	]
