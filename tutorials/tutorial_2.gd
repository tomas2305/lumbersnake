extends Node2D
var ended = false
var has_processed_ended := false

@onready var nav: TileMapLayer = $TutorialBackground
@onready var arrow: Sprite2D = $Arrow
@export var curse_duration: float = 100.0

@onready var tree_container: Node2D = $CursedTreeContainer
@onready var lock: StaticBody2D = $Lock
@onready var timer: Timer = $Timer
@onready var hud_layer: CanvasLayer = $HUDLayer
var idle_music = load("res://assets/mystry-forest-278844.mp3")
var chasing_music = load("res://assets/imminent-contact-dark-hybrid-trailer-horror-action-music-215163.mp3")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arrow.hide()
	timer.wait_time = curse_duration
	timer.start()
	hud_layer.set_curse_timer(curse_duration)
	Music.reproducir_musica(preload("res://assets/mystry-forest-278844.mp3"))

	#set_tags()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if tree_container.get_child_count() == 0:
		end_tutorial()
	else:
		var elapsed_time = curse_duration - timer.time_left
		hud_layer.set_curse_bar(elapsed_time)


		
func set_tags():
	pass
		
func end_tutorial():
	if not ended:
		ended = true
		timer.stop()
		hud_layer.restore_time()
		if is_instance_valid(lock):
			lock.queue_free()
		arrow.show()

func _on_level_area_body_entered(_body: Node2D) -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_timer_timeout() -> void:
	restart_tutorial()

func _on_player_chased() -> void:
	restart_tutorial()
	
func restart_tutorial() -> void:
	get_tree().reload_current_scene()
	
