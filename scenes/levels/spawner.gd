extends Line2D

@onready var SpritePreloader: ResourcePreloader = $"../SpritePreloader"
@onready var Reflector := $"../../"

var character_scene := preload("res://scenes/entities/character.tscn")
var character_reflection_scene := preload("res://scenes/entities/character_reflection.tscn")
var mirror_bottom: float

func spawn_character(Characters: Node2D, Reflections: Node2D) -> void:
	var new_character = character_scene.instantiate()
	new_character.set("global_position", get_random_spawn_location())
	new_character.set_sprites(SpritePreloader)
	Characters.add_child(new_character)
	if RNG.randi_in_range(0, 9) == 0:
		new_character.is_vampire = true
		return
	spawn_reflection(new_character, Reflections)


func spawn_reflection(character: CharacterBody2D, Reflections: Node2D) -> void:
	var new_reflection = character_reflection_scene.instantiate()
	new_reflection.set_corresponding_character(character)
	Reflections.add_child(new_reflection)
	new_reflection.mirrors_edge = mirror_bottom


func get_random_spawn_location() -> Vector2:
	return points[0].lerp(points[1], RNG.rand_weight())
