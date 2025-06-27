extends Area2D

signal player_entered_bush(body: Node2D)
signal player_exited_bush(body: Node2D)

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("bushes")
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered_bush.emit(body)
		sprite_2d.modulate.a = 0.6

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_exited_bush.emit(body)
		sprite_2d.modulate.a = 1
