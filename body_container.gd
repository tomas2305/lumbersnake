# BodyContainer.gd
extends Node2D

# — Texturas exportadas —
@export var body_texture: Texture2D
@export var tail_texture: Texture2D

# — Cantidad total de sprites (incluyendo la cola) —
@export var segment_count: int = 5

# — Delay (en frames) entre cada segmento —
@export var frames_delay_per_segment: int = 10

# — Offset de rotación (en radianes) —
@export var segment_rotation_offset: float = -PI / 2

# — Historial de posiciones de la cabeza —
var positions_history: Array = []


func _ready() -> void:
	_create_body_and_tail()
	_init_positions_history()
	_initialize_body_orientation()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	var head_pos = get_parent().global_position
	positions_history.insert(0, head_pos)

	var max_history = _body_segment_count() * frames_delay_per_segment + 1
	if positions_history.size() > max_history:
		positions_history.resize(max_history)

	_update_body_segments()


# — Instancia los N–1 sprites de cuerpo y luego 1 sprite de cola —
func _create_body_and_tail() -> void:
	# Liberamos hijos previos (si recarga la escena)
	for child in get_children():
		child.queue_free()

	# Cantidad de “cuerpo” (sin contar la cola)
	var body_only_count = max(segment_count - 1, 0)

	# 1) Creamos body_only_count sprites con body_texture
	for i in range(body_only_count):
		var seg_sprite = Sprite2D.new()
		seg_sprite.texture = body_texture
		seg_sprite.centered = true
		add_child(seg_sprite)
		seg_sprite.name = "BodySegment_%d" % i

	# 2) Por último, creamos un sprite de cola (tail) si segment_count >= 1
	if segment_count > 0:
		var tail_sprite = Sprite2D.new()
		tail_sprite.texture = tail_texture
		tail_sprite.centered = true
		add_child(tail_sprite)
		tail_sprite.name = "TailSegment"


func _init_positions_history() -> void:
	var needed_length = _body_segment_count() * frames_delay_per_segment + 1
	positions_history.clear()
	var head_pos = get_parent().global_position
	for i in range(needed_length):
		positions_history.append(head_pos)


func _initialize_body_orientation() -> void:
	var head_pos = get_parent().global_position
	var head_rot = get_parent().rotation

	for segment in get_children():
		segment.global_position = head_pos
		segment.rotation = head_rot + segment_rotation_offset


func _body_segment_count() -> int:
	return get_child_count()


func _update_body_segments() -> void:
	# Recorremos cada hijo en orden, desde el body hasta la cola
	for i in range(_body_segment_count()):
		var segment = get_child(i)
		var index_in_history = (i + 1) * frames_delay_per_segment
		if index_in_history >= positions_history.size():
			continue

		var target_pos: Vector2 = positions_history[index_in_history]
		segment.global_position = target_pos

		var prev_pos: Vector2
		if i == 0:
			prev_pos = positions_history[0]
		else:
			var prev_index = i * frames_delay_per_segment
			prev_pos = positions_history[prev_index]

		var dir_vec = target_pos - prev_pos
		if dir_vec.length() > 0:
			segment.rotation = dir_vec.angle() + segment_rotation_offset
