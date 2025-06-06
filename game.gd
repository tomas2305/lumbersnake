extends Node

@export var game_over_scene : PackedScene
@onready var nav_layer = $Nav

var gate = [Vector2i(-3,1),
			Vector2i(-3,2),
			Vector2i(-3,3),
			Vector2i(-3,4),]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Arrow.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.won:
		$Arrow.show()
		open_gate()
		


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
