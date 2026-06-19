extends Node

signal simulation_tick
signal day_started(day_number: int)
signal night_started(day_number: int)
signal time_updated(day_number: int, phase_name: String, time_remaining: float, phase_progress: float)

@export var day_length_seconds: float = 60.0
@export var night_length_seconds: float = 30.0
@export var simulation_tick_seconds: float = 1.0

var day_number: int = 1
var is_daytime: bool = true
var phase_elapsed: float = 0.0
var tick_elapsed: float = 0.0

func _ready() -> void:
	time_updated.emit(day_number, get_phase_name(), get_time_remaining(), get_phase_progress())

func _process(delta: float) -> void:
	phase_elapsed += delta
	tick_elapsed += delta

	if tick_elapsed >= simulation_tick_seconds:
		tick_elapsed = 0.0
		simulation_tick.emit()

	var current_length := get_current_phase_length()
	if phase_elapsed >= current_length:
		phase_elapsed = 0.0
		is_daytime = not is_daytime

		if is_daytime:
			day_number += 1
			day_started.emit(day_number)
		else:
			night_started.emit(day_number)

	time_updated.emit(day_number, get_phase_name(), get_time_remaining(), get_phase_progress())

func get_current_phase_length() -> float:
	if is_daytime:
		return day_length_seconds
	return night_length_seconds

func get_phase_name() -> String:
	if is_daytime:
		return "Day"
	return "Night"

func get_time_remaining() -> float:
	return maxf(get_current_phase_length() - phase_elapsed, 0.0)

func get_phase_progress() -> float:
	var current_length := get_current_phase_length()
	if current_length <= 0.0:
		return 0.0
	return clampf(phase_elapsed / current_length, 0.0, 1.0)
