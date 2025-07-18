extends Node2D

signal player_nearby

@onready var area := $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		emit_signal("player_nearby", self, body)

func change_color():
	animation_player.play("change_color")
