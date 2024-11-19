extends Control

@onready var Health := $MarginContainer/HBoxContainer/Blood
@onready var Animator := $MarginContainer/HBoxContainer2/AnimationPlayer
@onready var Focus := $MarginContainer/HBoxContainer2/Focus1
@onready var Focus2 := $MarginContainer/HBoxContainer2/Focus2

var focus := 0
var consuming_focus := false


func _process(_delta):
	Focus.value = focus
	Focus2.value = focus


func update_health(new_health: int) -> void:
	Health.value = new_health


func gain_focus() -> void:
	if consuming_focus or focus == 100:
		return
	focus += 2
	if focus == 50:
		Animator.play("pulse")
	elif focus == 100:
		Animator.play("pulse_2")


func reset_focus():
	focus = 0
	Animator.play("RESET")


func activate_focus() -> int:
	if focus < 50:
		return 0
	elif focus < 100:
		consume_focus()
		return 50
	else:
		consume_focus()
		return 100


func consume_focus() -> void:
	consuming_focus = true
	var tween = get_tree().create_tween()
	if focus == 100:
		await tween.tween_property(self, "focus", 0, 8).finished
	else:
		await tween.tween_property(self, "focus", focus - 50, 8).finished
	consuming_focus = false
