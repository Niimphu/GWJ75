extends Control

@onready var Volume := $Volume
@onready var Animator := $AnimationPlayer
@onready var Tutorial := $Tutorial

var paused = true

func _ready():
	Volume.visible = false
	Tutorial.visible = true


func _process(_delta):
	if get_node_or_null("Tutorial"):
		return
	if Input.is_action_just_pressed("pause"):
		if not paused:
			paused = true
			God.pause.emit()
			Volume.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Volume.visible = false
			resume()


func _on_main_menu_button_down():
	Animator.play("fade_out")


func _on_animation_player_animation_finished(_anim_name):
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_start_button_down():
	Tutorial.queue_free()
	resume()


func resume() -> void:
	paused = false
	God.resume.emit()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_back_button_down():
	resume()
