extends Node2D

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var vision_area: Area2D = $VisionArea

const COLOR_IDLE := Color(1, 1, 0, 0.2)  # Amarillo claro
const COLOR_ALERT := Color(1, 0.5, 0, 0.3)  # Naranja
const COLOR_CHASE := Color(1, 0, 0, 0.3)  # Rojo

@export var idle_sway_angle: float = 0.05
@export var idle_sway_speed: float = 0.30
@export var rot_stiffness: float = 6.0
@export var rot_damping: float = 5.0
@export var rotation_offset: float = deg_to_rad(10)
@export var chase_rot_speed: float = 12.0

var _time_accumulator := 0.0
var _target_player: Node2D = null
var _rot_vel := 0.0
var _state := 0  # Referencia a Enemy.State

func _ready() -> void:
	polygon_2d.color = COLOR_IDLE
	vision_area.monitoring = true
	vision_area.body_entered.connect(_on_body_entered)
	vision_area.body_exited.connect(_on_body_exited)
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	var parent_enemy = get_parent()
	if parent_enemy == null:
		return

	_time_accumulator += delta

	var target_base: float
	if _state == parent_enemy.State.CHASE and _target_player:
		var dir_to_player = (_target_player.global_position - parent_enemy.global_position).normalized()
		if dir_to_player.length() > 0.01:
			target_base = dir_to_player.angle() - PI / 2
		else:
			target_base = rotation

		var target_rot = target_base + rotation_offset
		rotation = lerp_angle(rotation, target_rot, chase_rot_speed * delta)
	else:
		var dir_idle = parent_enemy.velocity.normalized()
		if dir_idle.length() > 0.01:
			var base_rot = dir_idle.angle() - PI / 2
			var sway = sin(TAU * idle_sway_speed * _time_accumulator) * idle_sway_angle
			target_base = base_rot + sway
		else:
			target_base = rotation

		var target_rot = target_base + rotation_offset
		var diff = wrapf(target_rot - rotation, -PI, PI)
		var rot_acc = diff * rot_stiffness - _rot_vel * rot_damping
		_rot_vel += rot_acc * delta
		rotation += _rot_vel * delta

	global_position = parent_enemy.global_position

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		_target_player = body
		var parent_enemy = get_parent()
		if parent_enemy and parent_enemy.has_method("start_chase"):
			parent_enemy.start_chase(body)

func _on_body_exited(body: Node) -> void:
	if (body.is_in_group("Player") or body.name == "Player") and _target_player == body:
		_target_player = null
		var parent_enemy = get_parent()
		if parent_enemy and parent_enemy.has_method("stop_chase"):
			parent_enemy.stop_chase()

func set_state(new_state: int) -> void:
	_state = new_state
	match _state:
		0: polygon_2d.color = COLOR_IDLE
		1: polygon_2d.color = COLOR_ALERT
		2: polygon_2d.color = COLOR_CHASE
