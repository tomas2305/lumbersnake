extends Camera2D

@export var max_shake: float = 0
@export var shake_fade: float = 0
@export  var zoom_default : Vector2 = Vector2(1, 1)
@export  var zoom_in_value : Vector2 = Vector2(0.5, 0.5)

@onready var player = get_tree().get_first_node_in_group("player")

var fixed_position := Vector2.ZERO
var is_zooming_in := false
var _shake_strength: float = 0.0
var _target_offset: Vector2 = Vector2.ZERO
var _direction_offset: Vector2 = Vector2.ZERO
var _player: Node2D
var zoom_target: Vector2 = Vector2(1, 1)


func _ready():
	fixed_position = global_position
	zoom = zoom_default
	zoom_target = zoom_default
	make_current()

func trigger_shake():
	print("SHAKE SHAKE!")
	_shake_strength = max_shake

func _process(delta: float) -> void:
	# Shake offset
	if _shake_strength > 0:
		_shake_strength = lerp(_shake_strength, 0.0, shake_fade * delta)
	var shake_offset = Vector2(randf_range(-_shake_strength, _shake_strength), randf_range(-_shake_strength, _shake_strength))

	# Posición de destino con shake incluido
	var target_pos: Vector2
	if is_zooming_in and is_instance_valid(player):
		target_pos = player.global_position + shake_offset
	else:
		target_pos = fixed_position + shake_offset

	global_position = global_position.lerp(target_pos, 5.0 * delta)

	# Interpolación de zoom
	zoom = zoom.lerp(zoom_target, 5.0 * delta)
	
func zoom_in_on_player():
	if not is_instance_valid(player): return
	is_zooming_in = true
	zoom_target = zoom_in_value

func return_to_fixed_view():
	is_zooming_in = false
	zoom_target = zoom_default
