extends CharacterBody2D

@export var is_vampire :=  false

var scale_factor: float = 1.0
var direction := Vector2.ZERO

func _physics_process(_delta):
	get_input()
	move()
	scale_size()


func get_input() -> void:
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")


func move() -> void:
	velocity = direction * 350
	velocity = velocity.limit_length(350)
	move_and_slide()


func scale_size() -> void:
	var screen_y := DisplayServer.screen_get_size().y
	scale_factor = lerp(1.0, 1.3, global_position.y / screen_y)
	
	scale = Vector2(scale_factor, scale_factor)
