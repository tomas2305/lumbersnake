extends Camera2D

@export var max_shake: float = 0
@export var shake_fade: float = 0
@export var offset_distance: float = 24.0
@export var offset_smoothness: float = 0
@export  var zoom_default : Vector2 = Vector2(1, 1)
@export  var zoom_out_value : Vector2 = Vector2(0.7, 0.7) 

@onready var player = get_tree().get_first_node_in_group("player")

var _shake_strength: float = 0.0
var _target_offset: Vector2 = Vector2.ZERO
var _direction_offset: Vector2 = Vector2.ZERO
var _player: Node2D
var zoom_target: Vector2 = Vector2(1, 1)


func _ready():
	zoom = zoom_default
	zoom_target = zoom_default

func trigger_shake():
	_shake_strength = max_shake

func _process(delta: float) -> void:
	# Direccion del jugador (solo si tiene velocidad)
	var dir := Vector2.ZERO
			
	zoom = zoom.lerp(zoom_target, 5.0 * delta)

	# Objetivo de desplazamiento direccional
	_target_offset = dir * offset_distance
	_direction_offset = lerp(_direction_offset, _target_offset, offset_smoothness * delta)

	# Shake
	if _shake_strength > 0:
		_shake_strength = lerp(_shake_strength, 0.0, shake_fade * delta)
	var shake_offset = Vector2(randf_range(-_shake_strength, _shake_strength), randf_range(-_shake_strength, _shake_strength))

	# Offset final
	offset = _direction_offset + shake_offset

func zoom_out():
	zoom_target = zoom_out_value

func set_zoom_default():
	zoom_target = zoom_default
