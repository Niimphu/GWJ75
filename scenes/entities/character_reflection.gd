extends Node2D

## 1 means reflection's distance to bottom of mirror is same as distance from mirror to character. Lower value -> reflection is closer to bottom.
@export var DEPTH_FACTOR := 0.42

@onready var Camera: Camera2D = $"../../../Camera2D"
@onready var Animator: AnimationPlayer = $AnimationPlayer

var mirrors_edge: float = 12345
var Character: CharacterBody2D
var CharacterBase: Sprite2D
var CharacterLegs: Sprite2D
var Base: Sprite2D
var Legs: Sprite2D


func set_corresponding_character(corresponding_character: CharacterBody2D):
	Character = corresponding_character
	Character.kill.connect(character_killed)
	CharacterBase = Character.get_child(0).get_child(1)
	CharacterLegs = Character.get_child(0).get_child(4)
	
	var sprite: Node2D = Character.get_child(0).duplicate()
	add_child(sprite)
	Base = sprite.get_child(1)
	Legs = sprite.get_child(4)
	modulate = Color.LIGHT_SKY_BLUE


func _process(_delta):
	if !Character:
		return
	apply_reflection_effect()
	update_sprites()


func update_sprites():
	Base.frame = CharacterBase.frame
	Legs.frame = CharacterLegs.frame


func apply_reflection_effect() -> void:
	var real_pos: Vector2 = Character.global_position
	var reflection_offset := (real_pos.y - mirrors_edge) * DEPTH_FACTOR
	
	global_position = Vector2(real_pos.x, mirrors_edge - reflection_offset)
	var scale_factor: float = 2 - Character.scale_factor
	scale = Vector2(scale_factor, scale_factor)


func character_killed() -> void:
	Animator.play("death")
	await Animator.animation_finished
	queue_free()
