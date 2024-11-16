extends Control


func _on_sfx_value_changed(value):
	AudioServer.set_bus_volume_db(1, value)


func _on_env_value_changed(value):
	AudioServer.set_bus_volume_db(1, value)


func _on_music_value_changed(value):
	AudioServer.set_bus_volume_db(1, value)


func _on_back_button_down():
	self.visible = false
	God.resume.emit()
