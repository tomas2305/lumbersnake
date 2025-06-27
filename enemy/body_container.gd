extends Node2D

@export var segment_scene: PackedScene
@export var body_texture: Texture2D
@export var tail_texture: Texture2D
@export var segment_count: int = 5
@export var frames_delay_per_segment: int = 10
@export var segment_rotation_offset: float = -PI / 2

var positions_history: Array = []

func _ready() -> void:
	_create_body_and_tail()
	_init_positions_history()
	_initialize_body_orientation()
	set_physics_process(true)

func _physics_process(_delta: float) -> void:
	var head_pos = get_parent().global_position
	positions_history.insert(0, head_pos)
	var max_history = _body_segment_count() * frames_delay_per_segment + 1
	if positions_history.size() > max_history:
		positions_history.resize(max_history)
	_update_body_segments()

func _create_body_and_tail() -> void:
	for child in get_children():
		child.queue_free()

	var body_only_count = max(segment_count - 1, 0)

	for i in range(body_only_count):
		var seg = segment_scene.instantiate()
		var sprite = seg.get_node("Sprite2D")
		sprite.texture = body_texture
		add_child(seg)
		seg.name = "BodySegment_%d" % i

		if seg.has_signal("player_nearby"):
			seg.player_nearby.connect(_on_segment_player_nearby)

	if segment_count > 0:
		var tail = segment_scene.instantiate()
		var sprite = tail.get_node("Sprite2D")
		sprite.texture = tail_texture
		add_child(tail)
		tail.name = "TailSegment"

		if tail.has_signal("player_nearby"):
			tail.player_nearby.connect(_on_segment_player_nearby)

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

func _on_segment_player_nearby(_segment: Node, body: Node) -> void:
	var enemy = get_parent()
	if enemy and enemy.has_method("start_chase"):
		enemy.start_chase(body)
