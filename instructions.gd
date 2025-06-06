extends Control

@onready var close_button := $VBoxContainer/CloseButton

func _ready():
	show()
	get_tree().paused = true


func _on_close_button_pressed() -> void:
	get_tree().paused = false
	hide()
