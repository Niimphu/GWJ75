extends CharacterBody2D

var is_vampire :=  false

@onready var Base: Sprite2D = $Sprites/Base
@onready var Body: Sprite2D = $Sprites/Body
@onready var Face: Sprite2D = $Sprites/Face
@onready var Legs: Sprite2D = $Sprites/Legs
@onready var Shadow: Sprite2D = $Sprites/Shadow
@onready var Animator: AnimationPlayer = $AnimationPlayer
@onready var BloodSpray: CPUParticles2D = $BloodSpray
@onready var Dust: CPUParticles2D = $Dust


var speed: float = 50
var direction := Vector2.RIGHT
var scale_factor: float = 1.0
var time := 0.0
var alive := true

var base: int
var body: int
var face: int
var legs: int

signal kill
signal mouse_on(character: CharacterBody2D)
signal mouse_off(character: CharacterBody2D)

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
	
	Animator.animation_finished.connect(die)


func _physics_process(_delta):
	if alive:
		move()


func _process(delta):
	time += delta * 500
	if alive and time > speed:
		time = 0
		update_sprite_frames()
	scale_size()


func update_sprite_frames() -> void:
	if Base.frame == base + 6:
		Base.frame = base
		Legs.frame = legs
	else:
		Base.frame += 1
		Legs.frame += 1


func move() -> void:
	direction.y += RNG.randf_modifier()
	direction.y = clampf(direction.y, -0.3, 0.3)
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
	Shadow.set_texture(SpritePreloader.get_shadow())


func be_shot() -> void:
	$CollisionShape2D.disabled = true
	kill.emit()
	alive = false
	death_animation()


func death_animation() -> void:
	if not is_vampire:
		BloodSpray.restart()
		Animator.play("death")
	else:
		Dust.restart()
		Animator.play("fade")


func die(_anim_name = null) -> void:
	queue_free()


func _on_hurtbox_mouse_entered():
	mouse_on.emit(self)


func _on_hurtbox_mouse_exited():
	mouse_off.emit(self)
