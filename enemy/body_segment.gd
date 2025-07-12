extends Node2D

signal player_nearby

@onready var area := $Area2D

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player and not body.is_hidden:
		emit_signal("player_nearby", self, body)
