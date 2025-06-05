extends enemy_movement
class_name Enemy

@export var player: Node2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var body_container: Node2D = $BodyContainer
@onready var vision_cone: Node2D = $VisionCone

const ACCELERATION := 400.0
@export var MAX_SPEED := 90.0
@export var WALK_SPEED := 70.0

enum State { IDLE, ALERT, CHASE }
var state: State = State.IDLE
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
	match state:
		State.CHASE:
			if target_player:
				agent.target_position = target_player.global_position

		State.ALERT:
			if agent.is_navigation_finished():
				set_state(State.IDLE)
				random_generation()

		State.IDLE:
			if agent.is_navigation_finished():
				movement()

	var next_point = agent.get_next_path_position()
	var desired_dir = Vector2.ZERO
	if global_position.distance_to(next_point) >= 1.0:
		desired_dir = (next_point - global_position).normalized()
	else:
		if state == State.IDLE:
			movement()
			next_point = agent.get_next_path_position()
			desired_dir = (next_point - global_position).normalized()

	var desired_speed = WALK_SPEED
	if state in [State.CHASE, State.ALERT]:
		desired_speed = MAX_SPEED

	var desired_vel = desired_dir * desired_speed
	velocity = velocity.move_toward(desired_vel, ACCELERATION * delta)
	move_and_slide()

	vision_cone.global_position = global_position

func set_state(new_state: State) -> void:
	state = new_state
	if vision_cone.has_method("set_state"):
		vision_cone.set_state(state)

func start_chase(detected_player: Node2D) -> void:
	target_player = detected_player
	set_state(State.CHASE)
	agent.target_position = detected_player.global_position
	$RandomDir.stop()

func stop_chase() -> void:
	target_player = null
	set_state(State.IDLE)
	random_generation()
	$RandomDir.start()

func hear_sound(sound_position: Vector2) -> void:
	if state == State.IDLE:
		print("¡Enemigo escuchó un sonido!")
		set_state(State.ALERT)
		agent.target_position = sound_position

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		start_chase(body)

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body is Player:
		stop_chase()

func _on_random_dir_timeout() -> void:
	random_generation()
	$RandomDir.start()

func _on_vision_area_body_entered(body: Node2D) -> void:
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
