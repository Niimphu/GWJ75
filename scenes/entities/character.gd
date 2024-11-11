extends CharacterBody2D

@export var is_vampire :=  false

@onready var Sprite := $Sprite2D

var speed = 350

var scale_factor: float = 1.0
var direction := Vector2.RIGHT

signal kill


func _ready():
	speed += RNG.randi_in_range(-25, 25)
	await get_tree().create_timer(5).timeout
	die()


func _physics_process(_delta):
	scale_size()
	move()


func move() -> void:
	velocity = direction * 350
	velocity = velocity.limit_length(350)
	move_and_slide()


func scale_size() -> void:
	var screen_y := DisplayServer.screen_get_size().y
	scale_factor = lerp(1.0, 1.3, global_position.y / screen_y)
	
	scale = Vector2(scale_factor, scale_factor)


func set_sprite(new_sprite: Texture2D) -> void:
	await ready
	Sprite.set_texture(new_sprite)


func die() -> void:
	kill.emit()
	queue_free()
