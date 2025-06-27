extends Control
var win_music = load("res://assets/intro.mp3")
var loose_music = load("res://assets/mystry-forest-278844.mp3")

func _ready() -> void:
	if Global.won:
		setWonMessage()
		Music.reproducir_musica(win_music)
	else:
		setLooseMessage()
		Music.reproducir_musica(loose_music)
		

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("hit"):
		get_tree().change_scene_to_file("res://game.tscn")
		Global.reset()

func _on_again_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
	Global.reset()


func _on_quit_pressed() -> void:
		get_tree().quit()
		
		
func setWonMessage():
	$Mensaje.text = "El mal se repliega, has salvado el Bosque"
	
func setLooseMessage():
	$Mensaje.text = "La maldición se esparce, ¿Volverás a intentarlo?"


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/menu.tscn")
