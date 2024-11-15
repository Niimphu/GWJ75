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

var ammo := base_ammo
var reloading := false
var cocking := false


func _process(_delta):
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
	return true


func reload() -> void:
	reloading = true
	ReloadSound.play()
	ReloadTimer.start()


func _on_cocking_timer_timeout():
	cocking = false


func _on_reload_timer_timeout():
	ammo = base_ammo
	reloading = false


func _on_shoot_finished():
	if ammo:
		ReadySound.play()
	else:
		EmptySound.play()
