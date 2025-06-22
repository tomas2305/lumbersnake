extends Node2D
var ended = false
@onready var nav: TileMapLayer = $TutorialBackground
@onready var arrow: Sprite2D = $Arrow
@onready var chop_label: Label = $ChopLabel
@onready var movement_label: Label = $MovementLabel

@onready var tree: BaseTree = $BaseTree
@onready var tree_2: BaseTree = $BaseTree2


@onready var lock: StaticBody2D = $Lock


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_tags()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if tree == null and tree_2 == null:
		end_tutorial()

		
func set_tags():
	chop_label.text = "Destruye los arboles malditos presionando
	Talar ("+get_hit_button()+")"
	
	movement_label.text = "Movimiento con teclas
	
	Arriba ("+get_up_button()+")
	Abajo ("+get_down_button()+")
	Izquierda ("+get_left_button()+")
	Derecha ("+get_right_button()+")"
		
func end_tutorial():
	if not ended:
		ended = true
		if is_instance_valid(lock):
			lock.queue_free()
		arrow.show()

func _on_level_area_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://tutorials/tutorial_2.tscn")
	
func get_hit_button() -> String:
	var events = InputMap.action_get_events("hit")
	var key_event = events[0]
	return key_event.as_text().trim_suffix(" (Physical)")
	
func get_up_button() -> String:
	var events = InputMap.action_get_events("up")
	var key_event = events[0]
	return key_event.as_text().trim_suffix(" (Physical)")
	
func get_down_button() -> String:
	var events = InputMap.action_get_events("down")
	var key_event = events[0]
	return key_event.as_text().trim_suffix(" (Physical)")
	
func get_right_button() -> String:
	var events = InputMap.action_get_events("right")
	var key_event = events[0]
	return key_event.as_text().trim_suffix(" (Physical)")
	
func get_left_button() -> String:
	var events = InputMap.action_get_events("left")
	var key_event = events[0]
	return key_event.as_text().trim_suffix(" (Physical)")
	
