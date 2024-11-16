extends Node2D

@onready var hearts := get_children()

func lose_life() -> void:
	for heart in hearts:
		if heart.frame == 0:
			heart.frame = 1
			return
