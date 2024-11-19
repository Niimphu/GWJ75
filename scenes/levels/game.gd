extends Node2D

## Approximately 1 in vampire_rarity NPCs will be spawned as vampires
@export var vampire_rarity := 4
## How often difficulty increases in seconds
@export var difficulty_timer := 15
## Multiplier for time between vampire spawns each time difficulty increases
@export var difficulty_ramp := 0.9
## Frequency of NPC spawn (lower = more often)
@export var rate: float = 1

@onready var Camera: Camera2D = $Camera2D
@onready var CameraTracker := $Gun/Sprite2D/RemoteTransform2D
@onready var Characters: Node2D = $Characters
@onready var Reflections: Node2D = $Window/Reflections
@onready var Spawner: Line2D = $Spawner
@onready var Gun: Node2D = $Gun
@onready var HitSound := $Hit
@onready var Animator := $AnimationPlayer
@onready var Difficulty := $DifficultyTimer
@onready var screen_centre := Camera.get_screen_center_position()
@onready var Music: AudioStreamPlayer = $Music
@onready var Bus := $SchoolBus
@onready var UI := $"../UI"

var time := 0.0
var vampire_rate := 3
var spawns_since_vampire := 3
var runners_can_spawn = false
var characters_under_mouse: Array
var health := 100
var kill_streak := 0

var vampires_killed := 0
var runners_killed := 0
var civilians_killed := 0

var game_over := false
var resuming := true

signal gg(vamps: int, runners: int, civs, int)

func _ready():
	fade_in_music()
	
	Spawner.mirror_bottom = $Window.bottom_edge
	vampire_rate += RNG.randi_in_range(0, 2)
	
	Difficulty.wait_time = difficulty_timer
	Difficulty.start()
	Difficulty.timeout.connect(bump_difficulty)
	$SpawnRunners.start()
	
	if not God.skip_tutorial:
		get_tree().paused = true


func fade_in_music() -> void:
	var current_volume := Music.volume_db
	Music.volume_db = -80
	Music.play()
	var tween := get_tree().create_tween()
	tween.tween_property(Music, "volume_db", current_volume, 0.5)


func _physics_process(delta):
	if game_over:
		return
	if resuming:
		resuming = false
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		return
	time += delta
	if time > rate:
		@warning_ignore("narrowing_conversion")
		var spawn_count: int = time / rate
		time = 0
		for i in spawn_count:
			spawn_character()
	if Input.is_action_just_pressed("left_click") && Gun.shoot():
		shoot()
	elif Input.is_action_just_pressed("reload"):
		Gun.reload()
	elif Input.is_action_just_pressed("focus"):
		use_focus()


func shoot() -> void:
	if characters_under_mouse.is_empty() or God.shooting_bus:
		UI.reset_focus()
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
	
	characters_under_mouse.erase(shot_character)
	if !(is_instance_valid(shot_character)):
		return
	shot_character.be_shot()
	if shot_character.is_runner:
		runners_killed += 1
		UI.gain_focus()
		if !(runners_killed + vampires_killed) % 10:
			health += 1
			UI.update_health(health)
	elif shot_character.is_vampire:
		vampires_killed += 1
		UI.gain_focus()
		if !(runners_killed + vampires_killed) % 10:
			health += 1
			UI.update_health(health)
	else:
		civilians_killed += 1
		health -= 10
		UI.reset_focus()
		lose_life()


func use_focus() -> void:
	var effect: int = UI.activate_focus()
	if effect == 0:
		return
	#infinite ammo
	if effect == 100:
		pass
		#slow time


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
		health -= 20
		lose_life()


func lose_life() -> void:
	UI.update_health(health)
	Animator.play("flash_red")
	if health <= 0:
		end_game()


func bump_difficulty():
	rate *= difficulty_ramp
	difficulty_ramp *= 1.01


func end_game() -> void:
	game_over = true
	gg.emit(vampires_killed, runners_killed, civilians_killed)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Animator.play("fade")
	God.muffle_sound()


func mouse_over_character(character: CharacterBody2D):
	characters_under_mouse.append(character)


func mouse_off_character(character: CharacterBody2D):
	characters_under_mouse.erase(character)


func _on_shoot_finished():
	HitSound.play()


func _on_spawn_runners_timeout():
	runners_can_spawn = true
