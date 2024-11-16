extends CharacterBody2D

@onready var Base: Sprite2D = $Sprites/Base
@onready var Body: Sprite2D = $Sprites/Body
@onready var Face: Sprite2D = $Sprites/Face
@onready var Legs: Sprite2D = $Sprites/Legs

var base: int
var body: int
var face: int
var legs: int

var destination: Vector2
var direction: Vector2
var speed := 50
var time := 0.0


func _physics_process(_delta):
	if global_position.distance_squared_to(destination) < 2:
		set_process(false)
		if !RNG.randi_in_range(0, 100):
			random_move()
		Base.frame = base
		Legs.frame = legs
		return
	
	velocity = direction * speed
	move_and_slide()


func _process(delta):
	time += delta * 300
	if  time > speed:
		time = 0
		update_sprite_frames()


func random_move() -> void:
	set_process(true)
	destination = Vector2(RNG.randi_in_range(300, 550), RNG.randi_in_range(100, 275))
	direction = (destination - global_position).normalized()
	if direction.x < 0:
		Base.flip_h = true
		Legs.flip_h = true
		Body.flip_h = true
		Face.flip_h = true
	else:
		Base.flip_h = false
		Legs.flip_h = false
		Body.flip_h = false
		Face.flip_h = false


func update_sprite_frames() -> void:
	if Base.frame == base + 6:
		Base.frame = base
		Legs.frame = legs
	else:
		Base.frame += 1
		Legs.frame += 1


func _ready():
	random_move()
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
	
	colour_hair()


func colour_hair():
	var R := RNG.rand_weight() * 0.7
	var G := R * 0.9
	var B := G * RNG.rand_weight()
	
	Face.set_modulate(Color(R, G, B))
