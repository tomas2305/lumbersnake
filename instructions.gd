extends Control

@onready var close_button := $VBoxContainer/CloseButton

func _ready():
	if Global.first_run:
		show()
		get_tree().paused = true
		Global.first_run = false
	else:
		hide()


func _on_close_button_pressed() -> void:
	get_tree().paused = false
	hide()
	
func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		hide()
