extends Node2D

@onready var world_travelers_container: Node2D = $WorldTravelers

var traveler_markers: Dictionary = {}

func _ready() -> void:
	print("World Map scene loaded.")
	GameState.state_changed.connect(_refresh_world_travelers)
	_refresh_world_travelers()

func _process(_delta: float) -> void:
	_update_marker_positions_and_labels()

func _exit_tree() -> void:
	if GameState.state_changed.is_connected(_refresh_world_travelers):
		GameState.state_changed.disconnect(_refresh_world_travelers)

func _refresh_world_travelers() -> void:
	var active_ids: Array[int] = []

	for index in GameState.get_world_travelers().size():
		var traveler := GameState.get_world_travelers()[index]
		var traveler_id := int(traveler.get("id", index))
		active_ids.append(traveler_id)

		if not traveler_markers.has(traveler_id):
			var marker := _create_traveler_marker(traveler)
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

	_update_marker_positions_and_labels()

func _update_marker_positions_and_labels() -> void:
	var travelers := GameState.get_world_travelers()

	for index in travelers.size():
		var traveler := travelers[index]
		var traveler_id := int(traveler.get("id", index))

		if not traveler_markers.has(traveler_id):
			continue

		var marker: Node2D = traveler_markers[traveler_id]
		var base_position: Vector2 = traveler.get("world_position", Vector2(642, 430))
		var offset := Vector2((index % 5) * 22, int(index / 5) * 28)
		marker.position = base_position + offset

		var label := marker.get_node_or_null("Label") as Label
		if label != null:
			label.text = _build_traveler_label(traveler)

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
	label.position = Vector2(-55, -54)
	label.size = Vector2(180, 60)
	label.text = _build_traveler_label(traveler)
	marker.add_child(label)

	return marker

func _build_traveler_label(traveler: Dictionary) -> String:
	var inventory: Dictionary = traveler.get("inventory", {})
	return "%s\n%s\nHP %d/%d | P:%d G:%d" % [
		str(traveler.get("display_name", "Traveler")),
		str(traveler.get("status", "Unknown")),
		int(traveler.get("hp", 0)),
		int(traveler.get("max_hp", 0)),
		int(inventory.get("small_potion", 0)),
		int(inventory.get("slime_gel", 0))
	]
