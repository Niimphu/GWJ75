extends Control

func _ready():
	if God.skip_tutorial == true:
		close_tutorial()
		return
	visible = true


func close_tutorial():
	get_viewport().set_input_as_handled()
	get_tree().paused = false
	queue_free()


func _on_check_box_toggled(toggled_on):
	God.skip_tutorial = toggled_on


func _on_start_button_down():
	close_tutorial()
