# Enemy.gd
extends enemy_movement   # Se asume que enemy_movement hereda de CharacterBody2D
class_name Enemy

@export var player: Node2D
@onready var agent: NavigationAgent2D   = $NavigationAgent2D
@onready var detectionArea: Area2D       = $DetectionArea
@onready var body_container: Node2D      = $BodyContainer

@onready var vision_cone: Node2D       = $VisionCone

const COLOR_SEARCH := Color(1, 1, 0, 0.2)
const COLOR_ALERT  := Color(1, 0, 0, 0.3)

# Parámetros de suavizado
const ACCELERATION := 400.0
const MAX_SPEED := 90.0
const WALK_SPEED := 70.0

var playerDetected: bool = false
var target_player: Node2D = null

const MAP_WIDTH := 2000
const MAP_HEIGHT := 2000
const MIN_PATROL_DISTANCE := 300

func _ready() -> void:
	random_generation()
	if agent.target_position == Vector2.ZERO or global_position.distance_to(agent.target_position) < 1.0:
		agent.target_position = player.global_position
	vision_cone.get_node("VisionArea").body_entered.connect(_on_vision_area_body_entered)
	vision_cone.get_node("VisionArea").body_exited.connect(_on_vision_area_body_exited)
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	# 1) Si estamos en chase, mantener objetivo en el jugador
	if playerDetected and target_player:
		agent.target_position = target_player.global_position

	# 2) Si terminó la ruta y no hay chase, generar nuevo punto
	if not playerDetected and agent.is_navigation_finished():
		movement()

	# 3) Obtener siguiente punto y calcular dirección
	var next_point = agent.get_next_path_position()
	var desired_dir = Vector2.ZERO
	if global_position.distance_to(next_point) >= 1.0:
		desired_dir = (next_point - global_position).normalized()
	else:
		if not playerDetected:
			movement()
			next_point = agent.get_next_path_position()
			desired_dir = (next_point - global_position).normalized()

	# 4) Elegir velocidad según estado
	var desired_speed = WALK_SPEED
	if playerDetected:
		desired_speed = MAX_SPEED

	var desired_vel = desired_dir * desired_speed
	velocity = velocity.move_toward(desired_vel, ACCELERATION * delta)

	# 5) Mover al enemigo
	move_and_slide()

	# 6) Actualizar posición del VisionCone (la rotación la gestiona VisionCone.gd)
	vision_cone.global_position = global_position

func start_chase(detected_player: Node2D) -> void:
	playerDetected = true
	target_player = detected_player
	agent.target_position = detected_player.global_position

func stop_chase() -> void:
	playerDetected = false
	target_player = null
	random_generation()
	$RandomDir.start()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		playerDetected = true
		$RandomDir.stop()

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body is Player:
		playerDetected = false
		$RandomDir.start()

func _on_random_dir_timeout() -> void:
	random_generation()
	$RandomDir.start()

func _on_vision_area_body_entered(body: Node2D) -> void:
	# (La lógica de cambio de color y chase la maneja VisionCone.gd)
	pass

func _on_vision_area_body_exited(body: Node2D) -> void:
	pass

func movement():
	var new_target := Vector2.ZERO
	var tries := 0
	while true:
		new_target = Vector2(randf() * MAP_WIDTH, randf() * MAP_HEIGHT)
		if global_position.distance_to(new_target) >= MIN_PATROL_DISTANCE:
			break
		tries += 1
		if tries > 20:
			break
	agent.target_position = new_target
