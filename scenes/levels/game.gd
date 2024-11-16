extends Node2D

## Approximately 1 in vampire_rarity NPCs will be spawned as vampires
@export var vampire_rarity := 5
## How often difficulty increases in seconds
@export var difficulty_timer := 15
## Multiplier for time between vampire spawns each time difficulty increases
@export var difficulty_ramp := 0.9
## Frequency of NPC spawn (lower = more often)
@export var rate: float = 1.2

@onready var Camera: Camera2D = $Camera2D
@onready var CameraTracker := $Gun/Sprite2D/RemoteTransform2D
@onready var Characters: Node2D = $Characters
@onready var Reflections: Node2D = $Window/Reflections
@onready var Spawner: Line2D = $Spawner
@onready var Gun: Node2D = $Gun
@onready var HitSound := $Hit
@onready var MissSound := $Miss
@onready var Animator := $AnimationPlayer
@onready var Difficulty := $DifficultyTimer
@onready var screen_centre := Camera.get_screen_center_position()
#@onready var Bar := $UI/MarginContainer/HBoxContainer/VBoxContainer/ProgressBar
@onready var Hearts := $Health

var time := 0.0
var vampire_rate := 3
var spawns_since_vampire := 0
var runners_can_spawn = false
var characters_under_mouse: Array
var health := 3

var civilians_killed := 0
var vampires_killed := 0
var runners_killed := 0

var game_over := false
var paused := true
var resuming := false

func _ready():
	God.pause.connect(pause)
	God.resume.connect(resume)
	await God.resume
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	Spawner.mirror_bottom = $Window.bottom_edge
	vampire_rate += RNG.randi_in_range(0, 2)
	get_tree().create_timer(60).timeout.connect(spawn_runners)
	
	Difficulty.wait_time = difficulty_timer
	Difficulty.start()
	Difficulty.timeout.connect(bump_difficulty)


func _physics_process(delta):
	if game_over or paused:
		return
	time += delta
	if time > rate:
		@warning_ignore("narrowing_conversion")
		var spawn_count: int = time / rate
		time = 0
		for i in spawn_count:
			spawn_character()
	if resuming:
		resuming = false
		return
	if Input.is_action_just_pressed("left_click") && Gun.shoot():
		shoot()
	elif Input.is_action_just_pressed("reload"):
		Gun.reload()
	if Input.is_action_just_pressed("right_click"):
		var zoom_tween = get_tree().create_tween()
		zoom_tween.tween_property(Camera, "zoom", Vector2.ONE * 1.3, 0.1)
		CameraTracker.update_position = false
	elif Input.is_action_just_released("right_click"):
		CameraTracker.update_position = true
		var zoom_tween = get_tree().create_tween()
		zoom_tween.tween_property(Camera, "zoom", Vector2.ONE, 0.1)


func shoot() -> void:
	if characters_under_mouse.is_empty():
		MissSound.play()
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
		MissSound.play()
		return
	HitSound.play()
	characters_under_mouse.erase(shot_character)
	shot_character.be_shot()
	if shot_character.is_runner:
		runners_killed += 1
	elif shot_character.is_vampire:
		vampires_killed += 1
	else:
		civilians_killed += 1
		lose_life()


func spawn_runners() -> void:
	runners_can_spawn = true


func spawn_character() -> void:
	var new_character: CharacterBody2D
	if RNG.randi_in_range(0, vampire_rarity) == 0 or spawns_since_vampire > vampire_rarity:
		spawns_since_vampire = 0
		new_character = Spawner.spawn_character(Characters, Reflections, true, runners_can_spawn)
	else:
		spawns_since_vampire += 1
		new_character = Spawner.spawn_character(Characters, Reflections)
	
	new_character.mouse_on.connect(mouse_over_character)
	new_character.mouse_off.connect(mouse_off_character)
	new_character.fin.connect(character_reached_goal)


func character_reached_goal(is_vampire: bool) -> void:
	if game_over:
		return
	if is_vampire:
		lose_life()


func lose_life() -> void:
	Hearts.lose_life()
	Animator.play("flash_red")
	health -= 1
	if health <= 0:
		end_game()


func bump_difficulty():
	rate *= difficulty_ramp
	Difficulty.wait_time += 5


func end_game() -> void:
	game_over = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Animator.play("fade")
	muffle_sound()


func muffle_sound() -> void:
	AudioServer.set_bus_effect_enabled(1, 0, true)
	AudioServer.set_bus_effect_enabled(1, 1, true)
	AudioServer.set_bus_effect_enabled(2, 0, true)
	AudioServer.set_bus_effect_enabled(2, 1, true)
	AudioServer.set_bus_effect_enabled(3, 0, true)
	AudioServer.set_bus_effect_enabled(3, 1, true)


func mouse_over_character(character: CharacterBody2D):
	characters_under_mouse.append(character)


func mouse_off_character(character: CharacterBody2D):
	characters_under_mouse.erase(character)


func pause() -> void:
	paused = true


func resume() -> void:
	paused = false
	resuming = true
