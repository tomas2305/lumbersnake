extends Node2D
var ended = false
@onready var nav: TileMapLayer = $TutorialBackground
@onready var arrow: Sprite2D = $Arrow

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
	pass
		
func end_tutorial():
	if not ended:
		ended = true
		if is_instance_valid(lock):
			lock.queue_free()
		arrow.show()

func _on_level_area_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://game.tscn")
