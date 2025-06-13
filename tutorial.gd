extends Node2D
var ended = false
@onready var nav: TileMapLayer = $TutorialBackground
@onready var arrow: Sprite2D = $Arrow
@onready var label: Label = $Label

@onready var tree: BaseTree = $BaseTree
var gate = [Vector2i(23,1),
			Vector2i(23,2),
			Vector2i(23,3),
			Vector2i(23,4),
			Vector2i(23,4)]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Destruye los arboles malditos presionando
	Talar ("+get_hit_button()+")"
	arrow.hide()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if tree == null:
		ended = true
	if ended:
		open_gate()
		arrow.show()
		
		

func open_gate():
	for celda in gate:
		nav.erase_cell(celda) 
	


func _on_level_area_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://game.tscn")
	Music.reproducir_musica(preload("res://assets/mystry-forest-278844.mp3"))
	
func get_hit_button() -> String:
	var events = InputMap.action_get_events("hit")
	var key_event = events[0]
	return key_event.as_text().trim_suffix(" (Physical)")
	

	
