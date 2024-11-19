extends Control

@onready var Volume := $Volume
@onready var Animator := $AnimationPlayer
@onready var Game := $Game
@onready var GG := $GG

var to_menu := true

func _ready():
	Animator.play("fade_in")
	Volume.visible = false
	GG.visible = false
	God.reset_sound()
	Game.gg.connect(game_over)


func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		Volume.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		return


func game_over(vamps, runners, civs) -> void:
	GG.visible = true
	GG.set_stats(vamps, runners, civs)
	GG.game_over()


func _on_main_menu_button_down():
	Animator.play("fade_out")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_in":
		return
	if to_menu:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	else:
		get_tree().reload_current_scene()



func _on_restart_button_down():
	to_menu = false
	Animator.play("fade_out")


func _on_menu_button_down():
	Animator.play("fade_out")
