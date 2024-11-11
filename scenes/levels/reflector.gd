extends Control

@onready var Reflections = $Reflections

var bottom_edge: float = 0

func _ready():
	var bounding_rect := get_global_rect()
	bottom_edge = bounding_rect.size.y + bounding_rect.position.y
	
	for reflection in Reflections.get_children():
		reflection.mirrors_edge = bottom_edge
