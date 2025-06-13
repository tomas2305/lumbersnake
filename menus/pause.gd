extends Control



func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()

func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	show()
	
func testEsc():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()
		


func _on_resume_pressed() -> void:
	resume()
	

func _process(delta: float) -> void:
	testEsc()
func _on_reset_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_music_pressed() -> void:
	Music.toggle_mute()
	if (Music.esta_muted):
		$StopMusic/Sprite2D.texture = load("res://assets/volume-up.png")
	else:
		$StopMusic/Sprite2D.texture = load("res://assets/mute.png")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/input_settings.tscn")
