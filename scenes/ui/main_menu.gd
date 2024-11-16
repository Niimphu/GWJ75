extends Control

@onready var settings := $Volume


func _ready():
	settings.visible = false


func _on_play_button_down():
	$AnimationPlayer.play("fade_out")


func _on_settings_button_down():
	settings.visible = true


func _on_quit_pressed():
	get_tree().quit()


func _on_animation_player_animation_finished(_anim_name):
	get_tree().change_scene_to_file("res://scenes/levels/level.tscn")
