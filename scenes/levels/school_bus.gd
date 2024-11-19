extends Area2D

@onready var Animator := $AnimationPlayer
@onready var reset := global_position


func bussing() -> void:
	Animator.play("drive")


func _on_animation_player_animation_finished(_anim_name):
	global_position = reset


func _on_mouse_entered():
	God.shooting_bus = true


func _on_mouse_exited():
	God.shooting_bus = false


func _on_bus_timer_timeout():
	bussing()
