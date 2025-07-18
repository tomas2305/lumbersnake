extends Node

@export var game_over_scene : PackedScene
@onready var nav: TileMapLayer = $Map/Nav
@export var curse_duration: float = 120.0
@onready var hud_layer: CanvasLayer = $HUDLayer
@onready var tree_container: Node2D = $CursedTreeContainer
@onready var timer: Timer = $Timer

var has_processed_win := false
enum State { IDLE, ALERT, CHASE }
var idle_music = load("res://assets/mystry-forest-278844.mp3")
var chasing_music = load("res://assets/imminent-contact-dark-hybrid-trailer-horror-action-music-215163.mp3")

var gate = [Vector2i(-3,1),
			Vector2i(-3,2),
			Vector2i(-3,3),
			Vector2i(-3,4),]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = curse_duration
	timer.start()
	$Arrow.hide()
	Global.reset()
	hud_layer.set_curse_timer(curse_duration)
	Global.arboles_a_destruir = tree_container.get_child_count()
	
	Music.reproducir_musica(preload("res://assets/mystry-forest-278844.mp3"))

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Global.won and not has_processed_win:
		has_processed_win = true
		$Arrow.show()
		timer.stop()
		hud_layer.restore_time()
	elif !has_processed_win:
		var elapsed_time = curse_duration - timer.time_left
		hud_layer.set_curse_bar(elapsed_time)


func _on_timer_timeout() -> void:
	game_over()
	
	
func game_over():
	get_tree().change_scene_to_packed(game_over_scene)


func _on_player_chased() -> void:
	game_over()


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
	
