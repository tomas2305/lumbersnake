# VisionCone.gd
extends Node2D

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var vision_area: Area2D    = $VisionArea

const COLOR_SEARCH := Color(1, 1, 0, 0.2)
const COLOR_ALERT  := Color(1, 0, 0, 0.3)

# — Parámetros de oscilación en idle —
@export var idle_sway_angle: float = 0.05    # ±3° ≈ 0.05 rad
@export var idle_sway_speed: float = 0.30    # 0.3 ciclos/segundo

# — Parámetros del “muelle” para overshoot en rotación en idle —
@export var rot_stiffness: float = 6.0       # rigidez del muelle
@export var rot_damping: float = 5.0         # amortiguación (~2·sqrt(6) ≈ 4.9)

# — Offset adicional constante (radianes) —
@export var rotation_offset: float = deg_to_rad(10)  # 10° de offset

# — Velocidad de rotación directa en chase (sin overshoot) —
@export var chase_rot_speed: float = 12.0

var _time_accumulator := 0.0
var _in_chase := false
var _target_player: Node2D = null

# Estado interno: velocidad angular del muelle (solo usado en idle)
var _rot_vel := 0.0

func _ready() -> void:
	polygon_2d.color = COLOR_SEARCH
	vision_area.monitoring = true
	vision_area.body_entered.connect(_on_body_entered)
	vision_area.body_exited.connect(_on_body_exited)
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	var parent_enemy = get_parent()
	if parent_enemy == null:
		return

	_time_accumulator += delta

	# 1) Calcular ángulo deseado base (sin offset)
	var target_base: float
	if _in_chase and _target_player:
		# Chase: apunta directo al jugador (sin sway)
		var dir_to_player = (_target_player.global_position - parent_enemy.global_position).normalized()
		if dir_to_player.length() > 0.01:
			target_base = dir_to_player.angle() - PI/2
		else:
			target_base = rotation

		# En chase, rotamos vía lerp_angle con chase_rot_speed, sin usar muelle
		var target_rot = target_base + rotation_offset
		rotation = lerp_angle(rotation, target_rot, chase_rot_speed * delta)
	else:
		# Idle: apunta a la dirección real de movement (velocity) con un poco de sway + muelle
		var dir_idle = parent_enemy.velocity.normalized()
		if dir_idle.length() > 0.01:
			var base_rot = dir_idle.angle() - PI/2
			var sway = sin(TAU * idle_sway_speed * _time_accumulator) * idle_sway_angle
			target_base = base_rot + sway
		else:
			target_base = rotation

		# Dinámica de muelle para overshoot en idle
		var target_rot = target_base + rotation_offset
		var diff = wrapf(target_rot - rotation, -PI, PI)
		var rot_acc = diff * rot_stiffness - _rot_vel * rot_damping
		_rot_vel += rot_acc * delta
		rotation += _rot_vel * delta

	# Mantener el cono posicionado en la cabeza del Enemy
	global_position = parent_enemy.global_position

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		polygon_2d.color = COLOR_ALERT
		_in_chase = true
		_target_player = body
		var parent_enemy = get_parent()
		if parent_enemy and parent_enemy.has_method("start_chase"):
			parent_enemy.start_chase(body)

func _on_body_exited(body: Node) -> void:
	if (body.is_in_group("Player") or body.name == "Player") and _target_player == body:
		polygon_2d.color = COLOR_SEARCH
		_in_chase = false
		_target_player = null
		var parent_enemy = get_parent()
		if parent_enemy and parent_enemy.has_method("stop_chase"):
			parent_enemy.stop_chase()
