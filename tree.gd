extends Node2D

func _ready() -> void:
	$Node2D/Sprite2D.scale = Vector2(2,2)

func chop():
	queue_free()
