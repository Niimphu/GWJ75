extends CharacterBody2D

var is_vampire :=  false
var is_runner := false

@onready var Base: Sprite2D = $Sprites/Base
@onready var Body: Sprite2D = $Sprites/Body
@onready var Face: Sprite2D = $Sprites/Face
@onready var Legs: Sprite2D = $Sprites/Legs
@onready var Shadow: Sprite2D = $Sprites/Shadow
@onready var Animator: AnimationPlayer = $AnimationPlayer
@onready var BloodSpray: CPUParticles2D = $BloodSpray
@onready var Dust: CPUParticles2D = $Dust
@onready var Step := $Step
@onready var Death := $Death
@onready var Slurp := $Slurp


var speed: float = 55
var direction := Vector2.RIGHT
var scale_factor: float = 1.0
var time := 0.0
var alive := true
var time_mod := 500

var base: int
var body: int
var face: int
var legs: int

signal kill
signal fin(is_vampire: bool)
signal mouse_on(character: CharacterBody2D)
signal mouse_off(character: CharacterBody2D)

func _ready():
	speed += RNG.randi_in_range(-10, 10)
	if is_runner:
		speed *= 2
	
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
	Step.pitch_scale += RNG.rand_weight() * 2 - 0.5
	if is_vampire:
		Death.pitch_scale -= RNG.rand_weight() / 2
	else:
		Death.pitch_scale += RNG.rand_weight() - 0.3
	
	
	Animator.animation_finished.connect(die)


func _physics_process(_delta):
	if alive:
		move()


func colour_hair():
	var R := RNG.rand_weight() * 0.7
	var G := R * 0.9
	var B := G * RNG.rand_weight()
	
	Face.set_modulate(Color(R, G, B))


func _process(delta):
	time += delta * time_mod
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
	Slurp.stream = SpritePreloader.get_resource("schlurp")
	Step.stream = SpritePreloader.get_resource("step")
	#Step.play()
	if is_vampire:
		Death.stream = SpritePreloader.get_resource("ugh")
	else:
		Death.stream = SpritePreloader.get_resource("oof")


func be_shot() -> void:
	$CollisionShape2D.disabled = true
	Death.play(0.4)
	Step.stop()
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


func reached_goal() -> void:
	Animator.play("fade")
	if is_vampire:
		Slurp.play()
	fin.emit(is_vampire)


func die(_anim_name = null) -> void:
	queue_free()


func _on_hurtbox_mouse_entered():
	mouse_on.emit(self)


func _on_hurtbox_mouse_exited():
	mouse_off.emit(self)


func _on_step_finished():
	if alive:
		Step.play()
