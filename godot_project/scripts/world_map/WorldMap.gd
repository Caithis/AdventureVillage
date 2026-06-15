extends Node2D

@onready var world_travelers_container: Node2D = $WorldTravelers

func _ready() -> void:
	print("World Map scene loaded.")
	GameState.state_changed.connect(_refresh_world_travelers)
	_refresh_world_travelers()

func _exit_tree() -> void:
	if GameState.state_changed.is_connected(_refresh_world_travelers):
		GameState.state_changed.disconnect(_refresh_world_travelers)

func _refresh_world_travelers() -> void:
	for child in world_travelers_container.get_children():
		child.queue_free()

	var travelers := GameState.get_world_travelers()

	for index in travelers.size():
		var traveler := travelers[index]
		var marker := _create_traveler_marker(traveler, index)
		world_travelers_container.add_child(marker)

func _create_traveler_marker(traveler: Dictionary, index: int) -> Node2D:
	var marker := Node2D.new()
	marker.name = "WorldTraveler_%s" % str(traveler.get("id", index))

	var base_position: Vector2 = traveler.get("world_position", Vector2(642, 430))
	var offset := Vector2((index % 5) * 22, int(index / 5) * 28)
	marker.position = base_position + offset

	var body := ColorRect.new()
	body.name = "Body"
	body.size = Vector2(16, 16)
	body.position = Vector2(-8, -8)
	body.color = Color(0.75, 0.75, 0.95, 1)
	marker.add_child(body)

	var label := Label.new()
	label.name = "Label"
	label.position = Vector2(-42, -34)
	label.size = Vector2(120, 30)
	label.text = "%s\n%s" % [
		str(traveler.get("display_name", "Traveler")),
		str(traveler.get("status", "Near Town"))
	]
	marker.add_child(label)

	return marker
