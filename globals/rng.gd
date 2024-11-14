extends Node

var rng := RandomNumberGenerator.new()

func randi_in_range(a: int, b: int) -> int:
	return rng.randi_range(a, b)

func rand_weight() -> float:
	return rng.randf()

func randf_modifier() -> float:
	return rng.randf_range(-0.05, 0.05)
