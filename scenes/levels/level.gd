extends Node2D

@export var CAMERA_SPEED := 200

@onready var Camera: Camera2D = $Camera2D
@onready var Characters: Node2D = $Characters
@onready var Reflections: Node2D = $Window/Reflections
@onready var SpritePreloader: ResourcePreloader = $SpritePreloader

var character_scene := preload("res://scenes/entities/character.tscn")
var character_reflection_scene := preload("res://scenes/entities/character_reflection.tscn")

func _process(delta):
	var direction := 0.0
	direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if direction:
		Camera.global_position.x += direction * CAMERA_SPEED * delta
	
	if Input.is_action_just_pressed("left_click"):
		spawn_character(get_global_mouse_position())
	
	if Input.is_action_just_pressed("right_click"):
		spawn_reflection(Characters.get_child(0))


func spawn_character(spawn_position: Vector2) -> void:
	var new_character = character_scene.instantiate()
	new_character.set("global_position", spawn_position)
	new_character.set_sprite(SpritePreloader.get_random_sprite())
	Characters.add_child(new_character)
	if RNG.randi_in_range(0, 9) == 0:
		new_character.is_vampire = true
		return
	spawn_reflection(new_character)


func spawn_reflection(character: CharacterBody2D) -> void:
	var new_reflection = character_reflection_scene.instantiate()
	new_reflection.add_child(character.get_child(0).duplicate())
	new_reflection.Character = character
	new_reflection.set_process(true)
	Reflections.add_child(new_reflection)
