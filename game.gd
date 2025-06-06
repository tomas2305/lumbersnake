extends Node

@export var game_over_scene : PackedScene
@onready var nav_layer = $Nav
enum State { IDLE, ALERT, CHASE }
var idle_music = load("res://assets/mystry-forest-278844.mp3")
var chasing_music = load("res://assets/imminent-contact-dark-hybrid-trailer-horror-action-music-215163.mp3")


var gate = [Vector2i(-3,1),
			Vector2i(-3,2),
			Vector2i(-3,3),
			Vector2i(-3,4),]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Arrow.hide()
	Music.reproducir_musica(idle_music)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.won:
		$Arrow.show()
		open_gate()
		$Timer.stop()
	if $Timer.time_left > 0 :
		actualizar_label()
		


func _on_timer_timeout() -> void:
	game_over()
	
	
func game_over():
	
	get_tree().change_scene_to_packed(game_over_scene)


func _on_player_chased() -> void:
	game_over()

func open_gate():
	for celda in gate:
		nav_layer.erase_cell(celda) 


func _on_win_area_body_entered(body: Node2D) -> void:
	if body is Player:
		game_over()
	else: 
		pass


func _on_enemy_state_changed(new_state: Variant) -> void:
	if new_state == State.IDLE:
		Music.reproducir_musica(idle_music)
	else:
		Music.reproducir_musica(chasing_music) 
		
func actualizar_label():
	var minutos := int($Timer.time_left) / 60
	var segundos := int($Timer.time_left) % 60
	$TimerLabel.text = "%02d:%02d" % [minutos, segundos]


func _on_base_tree_chopped() -> void:
	if !Music.esta_muted:
		$ChoppedSound.play(0.0)
