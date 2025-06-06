extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.won:
		setWonMessage()
	else:
		setLooseMessage()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_again_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
	Global.reset()


func _on_quit_pressed() -> void:
		get_tree().quit()
		
		
func setWonMessage():
	$Mensaje.text = "El mal se repliega, has salvado el Bosque"
	
func setLooseMessage():
	$Mensaje.text = "La maldición se esparce, ¿Volverás a intentarlo?"
