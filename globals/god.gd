extends Node

var skip_tutorial: bool = false
var shooting_bus: bool = false


func reset_sound() -> void:
	AudioServer.set_bus_effect_enabled(0, 0, false)
	AudioServer.set_bus_effect_enabled(0, 1, false)


func muffle_sound() -> void:
	AudioServer.set_bus_effect_enabled(0, 0, true)
	AudioServer.set_bus_effect_enabled(0, 1, true)
