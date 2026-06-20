extends Node2D
class_name FloatingText

@onready var label: Label = $Label

var velocity: Vector2 = Vector2(0, -34)
var lifetime: float = 1.35
var age: float = 0.0

func setup(text: String, start_offset: Vector2 = Vector2.ZERO) -> void:
    position += start_offset

    if label != null:
        label.text = text

func _process(delta: float) -> void:
    age += delta
    position += velocity * delta

    var fade_ratio: float = 1.0 - clampf(age / lifetime, 0.0, 1.0)
    modulate.a = fade_ratio

    if age >= lifetime:
        queue_free()
