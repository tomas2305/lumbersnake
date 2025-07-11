extends Camera2D

@export var max_shake: float = 0
@export var shake_fade: float = 0

var _shake_stregth: float = 0.0

func trigger_shake():
	_shake_stregth = max_shake

func _process(delta: float) -> void:
	if _shake_stregth > 0:
		_shake_stregth = lerp(_shake_stregth, 0.0, shake_fade * delta)
	offset = Vector2(randf_range(-_shake_stregth, _shake_stregth), randf_range(-_shake_stregth, _shake_stregth))
