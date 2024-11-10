extends Node2D

@onready var Camera: Camera2D = $Camera2D

var CAMERA_SPEED := 200

func _process(delta):
	var direction := 0.0
	direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if direction:
		Camera.global_position.x += direction * CAMERA_SPEED * delta
