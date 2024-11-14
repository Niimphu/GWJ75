extends CharacterBody2D

@export var is_vampire :=  false

@onready var Base: Sprite2D = $Sprites/Base
@onready var Body: Sprite2D = $Sprites/Body
@onready var Face: Sprite2D = $Sprites/Face
@onready var Legs: Sprite2D = $Sprites/Legs
@onready var Ray1: RayCast2D= $Ray1
@onready var Ray2: RayCast2D= $Ray2

var speed = 50

var scale_factor: float = 1.0

var base: int
var body: int
var face: int
var legs: int

signal kill


func _ready():
	speed += RNG.randi_in_range(-15, 15)
	
	base = RNG.randi_in_range(1, 3) * 7
	if base == 7:
		base = 0
	body = RNG.randi_in_range(0, 6)
	face = RNG.randi_in_range(0, 13)
	legs = RNG.randi_in_range(0, 3) * 7
	
	Base.frame = base
	Body.frame = body
	Face.frame = face
	Legs.frame = legs
	await get_tree().create_timer(15).timeout
	die()


func _physics_process(_delta):
	scale_size()
	move()


func move() -> void:
	var direction := Vector2.RIGHT
	
	if Ray1.is_colliding():
		direction.y += global_position.distance_to(Ray1.get_collision_point()) / 15
	elif Ray2.is_colliding():
		direction.y -= global_position.distance_to(Ray2.get_collision_point()) / 15
	direction = direction.normalized()
	
	velocity = direction * speed
	velocity = velocity.limit_length(speed)
	move_and_slide()


func scale_size() -> void:
	var screen_y := DisplayServer.screen_get_size().y
	scale_factor = lerp(1.0, 1.3, global_position.y / screen_y)
	
	scale = Vector2(scale_factor, scale_factor)


func set_sprites(SpritePreloader: ResourcePreloader) -> void:
	await ready
	Base.set_texture(SpritePreloader.get_base())
	Body.set_texture(SpritePreloader.get_body())
	Face.set_texture(SpritePreloader.get_face())
	Legs.set_texture(SpritePreloader.get_legs())


func die() -> void:
	kill.emit()
	queue_free()
