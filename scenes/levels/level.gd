extends Control

@onready var Volume := $Volume
@onready var Animator := $AnimationPlayer
@onready var Tutorial := $Tutorial
@onready var Game := $Game
@onready var GG := $GG

var paused = true
var to_menu := true

func _ready():
	Animator.play("fade_in")
	Volume.visible = false
	if God.skip_tutorial:
		Tutorial.visible = false
		_on_start_button_down()
	else:
		Tutorial.visible = true
	GG.visible = false
	God.reset_sound()
	
	Game.gg.connect(game_over)


func _process(_delta):
	if get_node_or_null("Tutorial"):
		return
	if Input.is_action_just_pressed("pause"):
		if GG.visible:
			return
		if not paused:
			paused = true
			God.pause.emit()
			Volume.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Volume.visible = false
			resume()


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


func _on_start_button_down():
	Tutorial.queue_free()
	resume()


func resume() -> void:
	paused = false
	God.resume.emit()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_back_button_down():
	resume()


func _on_restart_button_down():
	to_menu = false
	Animator.play("fade_out")


func _on_menu_button_down():
	Animator.play("fade_out")
