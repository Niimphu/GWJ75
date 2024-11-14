extends Node2D

## Approximately 1 in vampire_rarity NPCs will be spawned as vampires
@export var vampire_rarity := 5
## How often difficulty increases in seconds
@export var difficulty_timer := 5
## Multiplier for time between vampire spawns each time difficulty increases
@export var difficulty_ramp := 0.95
## Frequency of NPC spawn (lower = more often)
@export var rate: float = 1.2

@onready var Camera: Camera2D = $Camera2D
@onready var Characters: Node2D = $Characters
@onready var Reflections: Node2D = $Window/Reflections
@onready var Spawner: Line2D = $Spawner

var time := 0.0
var vampire_rate := 3
var spawns_since_vampire := 0
var runners_can_spawn = false

var characters_under_mouse: Array

func _ready():
	Spawner.mirror_bottom = $Window.bottom_edge
	vampire_rate += RNG.randi_in_range(0, 2)
	$DifficultyTimer.wait_time = difficulty_timer
	get_tree().create_timer(30).timeout.connect(spawn_runners)


func _physics_process(delta):
	time += delta
	if time > rate:
		@warning_ignore("narrowing_conversion")
		var spawn_count: int = time / rate
		time = 0
		for i in spawn_count:
			spawn_character()
	if Input.is_action_just_pressed("left_click"):
		shoot()


func shoot() -> void:
	if characters_under_mouse.is_empty():
		return
	
	var shot_character: CharacterBody2D = null
	for character in characters_under_mouse:
		if !(is_instance_valid(character)):
			characters_under_mouse.erase(character)
			continue
		if !shot_character:
			shot_character = character
		elif character.global_position.y > shot_character.global_position.y:
			shot_character = character
	
	if !shot_character:
		return
	characters_under_mouse.erase(shot_character)
	shot_character.be_shot()


func spawn_runners() -> void:
	runners_can_spawn = true


func spawn_character() -> void:
	var new_character: CharacterBody2D
	if RNG.randi_in_range(0, vampire_rarity) == 0 or spawns_since_vampire > vampire_rarity + 1:
		spawns_since_vampire = 0
		new_character = Spawner.spawn_character(Characters, Reflections, true, runners_can_spawn)
	else:
		spawns_since_vampire += 1
		new_character = Spawner.spawn_character(Characters, Reflections)
	
	new_character.mouse_on.connect(mouse_over_character)
	new_character.mouse_off.connect(mouse_off_character)


func _on_difficulty_timer_timeout():
	rate *= difficulty_ramp


func mouse_over_character(character: CharacterBody2D):
	characters_under_mouse.append(character)


func mouse_off_character(character: CharacterBody2D):
	characters_under_mouse.erase(character)
