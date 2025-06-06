extends Control




func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/input_settings.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
