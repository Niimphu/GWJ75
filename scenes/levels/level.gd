extends Node2D

@export var CAMERA_SPEED := 100

@onready var Camera: Camera2D = $Camera2D
@onready var Characters: Node2D = $Characters
@onready var Reflections: Node2D = $Window/Reflections
@onready var Spawner: Line2D = $Spawner

func _ready():
	Spawner.mirror_bottom = $Window.bottom_edge


func _process(delta):
	var direction := 0.0
	direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if direction:
		Camera.global_position.x += direction * CAMERA_SPEED * delta
	
	if Input.is_action_just_pressed("left_click"):
		Spawner.spawn_character(Characters, Reflections)
