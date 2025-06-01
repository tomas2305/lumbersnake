extends enemy_movement
class_name Enemy

# --- Parámetros para el cuerpo segmentado ---
const FRAMES_DELAY_PER_SEGMENT := 10
# Este offset en radianes corrige la orientación de los sprites de segmento
# Si tu sprite de segmento está dibujado apuntando hacia arriba, usa -PI/2.
# Si apuntara hacia la izquierda, usarías 0, etc. Ajusta según tu arte.
const SEGMENT_ROTATION_OFFSET := -PI / 2

@export var player: Node2D 
@onready var agent: NavigationAgent2D   = $NavigationAgent2D
@onready var detectionArea: Area2D       = $DetectionArea
@onready var body_container: Node2D      = $BodyContainer

var playerDetected = false
var positions_history: Array = []

func _ready() -> void:
	random_generation()
	_init_positions_history()
	_initialize_body_orientation()

func _physics_process(delta: float) -> void:
	# 1) Movimiento de la cabeza
	var next = agent.get_next_path_position()
	if global_position.distance_to(next) < 1000.0:
		velocity = Vector2.ZERO
	var dir = (next - global_position).normalized()
	if playerDetected:
		speed = 80
		velocity = dir * speed
	else:
		speed = 70
		movement()
	move_and_slide()

	# 2) Guardar la posición actual de la cabeza
	positions_history.insert(0, global_position)
	var max_history = body_container.get_child_count() * FRAMES_DELAY_PER_SEGMENT + 1
	if positions_history.size() > max_history:
		positions_history.resize(max_history)

	# 3) Actualizar segmentos
	_update_body_segments()

func _init_positions_history() -> void:
	# Inicia el historial con la posición actual repetida
	var needed_length = body_container.get_child_count() * FRAMES_DELAY_PER_SEGMENT + 1
	positions_history.clear()
	for i in range(needed_length):
		positions_history.append(global_position)

func _initialize_body_orientation() -> void:
	# Coloca cada segmento sobre la cabeza y le aplica la misma rotación
	# así no saltan mal alineados al iniciar.
	for segment in body_container.get_children():
		segment.global_position = global_position
		segment.rotation = rotation + SEGMENT_ROTATION_OFFSET

func _update_body_segments() -> void:
	for i in range(body_container.get_child_count()):
		var segment = body_container.get_child(i)
		var index_in_history = (i + 1) * FRAMES_DELAY_PER_SEGMENT
		if index_in_history >= positions_history.size():
			continue
		var target_pos: Vector2 = positions_history[index_in_history]
		segment.global_position = target_pos

		# Calcular rotación “dir” hacia su predecesor
		var prev_pos: Vector2
		if i == 0:
			prev_pos = positions_history[0]  # posición de la cabeza
		else:
			var prev_index = i * FRAMES_DELAY_PER_SEGMENT
			prev_pos = positions_history[prev_index]
		var dir = segment.global_position - prev_pos
		if dir.length() > 0:
			# Aplico offset para corregir orientación del sprite de segmento
			segment.rotation = dir.angle() + SEGMENT_ROTATION_OFFSET

func makepath() -> void:
	agent.target_position = player.global_position

func _on_timer_timeout() -> void:
	if playerDetected:
		makepath()

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
