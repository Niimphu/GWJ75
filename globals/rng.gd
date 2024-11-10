extends Node

var rng := RandomNumberGenerator.new()

func randi_in_range(a: int, b: int) -> int:
	return rng.randi_range(a, b)
