extends Node2D

@export var base_ammo := 5

@onready var CockingTimer := $CockingTimer
@onready var ReloadTimer := $ReloadTimer
@onready var ReloadSound := $Reload
@onready var ShootSound := $Shoot
@onready var ReadySound := $Ready
@onready var EmptySound := $Empty
@onready var Crosshair := $Sprite2D
@onready var Animator := $AnimationPlayer
@onready var BulletCounter := $Sprite2D/TextureProgressBar

var ammo := base_ammo
var reloading := false
var cocking := false
var paused := true

func _ready():
	God.pause.connect(pause)
	God.resume.connect(resume)


func pause():
	paused = true

func resume():
	paused = false


func _process(_delta):
	if paused:
		return
	Crosshair.global_position = get_global_mouse_position()


func shoot() -> bool:
	if reloading or cocking:
		return false
	if ammo == 0:
		EmptySound.play()
		return false
	Animator.play("recoil")
	ammo -= 1
	cocking = true
	CockingTimer.start()
	ShootSound.play()
	BulletCounter.value = ammo
	return true


func reload() -> void:
	if ammo == base_ammo:
		return
	ammo = 0
	BulletCounter.value = ammo
	reloading = true
	Crosshair.self_modulate = Color.DARK_SLATE_BLUE
	ReloadSound.play()
	ReloadTimer.start()


func _on_cocking_timer_timeout():
	cocking = false


func _on_reload_timer_timeout():
	ammo = base_ammo
	BulletCounter.value = ammo
	Crosshair.self_modulate = Color.WHITE
	reloading = false


func _on_shoot_finished():
	if ammo:
		ReadySound.play()
	else:
		EmptySound.play()
		reload()
