extends Control

func _ready() -> void:
	
	Music.reproducir_musica(preload("res://assets/intro.mp3"))

func _on_start_pressed() -> void:
	if Global.first_run:
		get_tree().change_scene_to_file("res://tutorials/tutorial_1.tscn")
	else:
		get_tree().change_scene_to_file("res://game.tscn")
		Music.reproducir_musica(preload("res://assets/mystry-forest-278844.mp3"))


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/input_settings.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_stop_music_pressed() -> void:
	Music.toggle_mute()
	if (Music.esta_muted):
		$StopMusic/Sprite2D.texture = load("res://assets/volume-up.png")
	else:
		$StopMusic/Sprite2D.texture = load("res://assets/mute.png")


func _on_tutorial_pressed() -> void:
	Global.first_run = false
	get_tree().change_scene_to_file("res://tutorials/tutorial_1.tscn")
