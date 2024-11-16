extends Control

@onready var SFX = $MarginContainer/VBoxContainer/SFX
@onready var ENV = $MarginContainer/VBoxContainer/Env
@onready var MUS = $MarginContainer/VBoxContainer/Music


func _ready():
	SFX.value_changed.connect(change_sfx)
	ENV.value_changed.connect(change_env)
	MUS.value_changed.connect(change_music)
	
	SFX.value = AudioServer.get_bus_volume_db(1)
	ENV.value = AudioServer.get_bus_volume_db(2)
	MUS.value = AudioServer.get_bus_volume_db(3)


func change_sfx(value):
	if value < -18:
		value = -80
	AudioServer.set_bus_volume_db(1, value)


func change_env(value):
	if value < -18:
		value = -80
	AudioServer.set_bus_volume_db(2, value)


func change_music(value):
	if value < -18:
		value = -80
	AudioServer.set_bus_volume_db(3, value)


func _on_back_button_down():
	self.visible = false
	God.resume.emit()
