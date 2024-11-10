extends Node2D

@export var DEPTH_FACTOR := 0.6
@export var PARALLAX_FACTOR := 0.5 #wth do i call this

@onready var Sprite: Sprite2D = $Sprite2D
@onready var Camera: Camera2D = $"../../../Camera2D"

var mirrors_edge: float = 12345
var Character: CharacterBody2D

func _ready():
	set_process(false)


func set_corresponding_character(corresponding_character: CharacterBody2D):
	Character = corresponding_character
	var og_sprite: Sprite2D = Character.get_child(0) #Sprite must be first child of character
	Sprite.texture = og_sprite.texture
	Sprite.offset = og_sprite.offset
	set_process(true)


func _process(_delta):
	apply_reflection_effect()


func apply_reflection_effect() -> void:
	var real_pos: Vector2 = Character.global_position
	var reflection_offset := (real_pos.y - mirrors_edge) * DEPTH_FACTOR
	var camera_x := Camera.get_screen_center_position().x
	var camera_offset: float  = (camera_x - real_pos.x) * lerp(0.1, 0.3, (reflection_offset / 300)) * PARALLAX_FACTOR
	
	global_position = Vector2(real_pos.x + camera_offset, mirrors_edge - reflection_offset)
	
	var scale_factor: float = 2 - Character.scale_factor
	scale = Vector2(scale_factor, scale_factor)
