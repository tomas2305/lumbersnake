extends Node2D

@export var danger_distance: float = 160.0
@export var fade_speed: float = 3.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy = get_tree().get_first_node_in_group("enemy")
@onready var top = $DangerTop
@onready var bottom = $DangerBottom
@onready var left = $DangerLeft
@onready var right = $DangerRight

var time_since_start := 0.0
var danger_active := false
@export var delay_to_activate := 1.0  # segundos

func _process(delta):
	time_since_start += delta
	if time_since_start >= delay_to_activate:
		danger_active = true

	if not danger_active:
		_hide_all()
		return

	var to_enemy = (enemy.global_position - player.global_position)
	var dist = to_enemy.length()

	var danger_strength = clamp(1.0 - (dist / danger_distance), 0.0, 1.0)

	var horizontal = to_enemy.x
	var vertical = to_enemy.y

	_fade_dir(left, danger_strength if horizontal < -16 else 0.0, delta)
	_fade_dir(right, danger_strength if horizontal > 16 else 0.0, delta)
	_fade_dir(top, danger_strength if vertical < -16 else 0.0, delta)
	_fade_dir(bottom, danger_strength if vertical > 16 else 0.0, delta)

func _hide_all():
	for rect in [left, right, top, bottom]:
		var color = rect.modulate
		color.a = 0.0
		rect.modulate = color

func _fade_dir(rect: TextureRect, target_alpha: float, delta: float):
	var current = rect.modulate.a
	var new_alpha = lerp(current, target_alpha, fade_speed * delta)
	var color = rect.modulate
	color.a = new_alpha
	rect.modulate = color
