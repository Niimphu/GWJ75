extends Control

@onready var nodes := [ $MarginContainer/MarginContainer/VBoxContainer/DeadVamps,
						$MarginContainer/MarginContainer/VBoxContainer/Runners,
						$MarginContainer/MarginContainer/VBoxContainer/Civs,
						$MarginContainer/MarginContainer/VBoxContainer/Buttons ]


func _ready():
	modulate.a = 0


func set_stats(vamp: int, runner: int, civ: int) -> void:
	nodes[0].text = "Vampires slain: " + str(vamp)
	nodes[1].text = "Runners slain: " + str(runner)
	nodes[2].text = "Civilians slain: " + str(civ)


func game_over() -> void:
	var tween := get_tree().create_tween()
	await tween.tween_property(self, "modulate", Color.WHITE, 2).finished
	for node in nodes:
		await get_tree().create_timer(0.5).timeout
		node.visible = true


func _on_check_box_toggled(toggled_on):
	God.skip_tutorial = toggled_on
