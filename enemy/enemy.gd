extends CharacterBody2D
class_name Enemy

signal state_changed(new_state)

@export var player: Node2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var vision_cone: Node2D = $VisionCone
@onready var animation_alert: AnimatedSprite2D = $AnimationAlert

const ACCELERATION := 400.0
@export var MAX_SPEED : float = 180
@export var BASE_WALK_SPEED : float = 150


var WALK_SPEED := BASE_WALK_SPEED

enum State { IDLE, ALERT, CHASE }
var state: State = State.IDLE
var target_player: Node2D = null

const MAP_WIDTH := 2000
const MAP_HEIGHT := 2000
const MIN_PATROL_DISTANCE := 300

var interest_zones: Array[Vector2] = []
var last_alert_position: Vector2 = Vector2.ZERO
var alert_steps := 0
const MAX_ALERT_STEPS := 3

var silent_zone: Vector2 = Vector2.ZERO
var silent_zone_weight := 0.0
const MAX_WEIGHT := 1.0

var protected_trees: Array[Node] = []
var total_trees := 0
var patrol_queue: Array = []
var patrol_points: Array = []

var route_timer := 0.0
const MAX_ROUTE_TIME := 10.0

func _ready() -> void:
	add_to_group("enemy")
	protected_trees = get_tree().get_nodes_in_group("cursed_trees")
	print("protected trees: ", protected_trees )
	total_trees = protected_trees.size()
	patrol_points = protected_trees.map(func(t): return t.global_position) 
	patrol_queue = patrol_points.duplicate()
	randomize_patrol_queue()

	for tree in protected_trees:
		if tree.has_signal("chopped_alert"):
			tree.connect("chopped_alert", Callable(self, "on_tree_chopped"))

	if player and player.has_signal("zona_peligro"):
		player.connect("zona_peligro", Callable(self, "on_player_idle"))

	if agent.target_position == Vector2.ZERO or global_position.distance_to(agent.target_position) < 1.0:
		agent.target_position = player.global_position

	set_physics_process(true)

func _physics_process(delta: float) -> void:
	update_route_timer(delta)
	handle_state_logic()
	handle_movement(delta)
	update_vision_cone()

func update_route_timer(delta: float) -> void:
	if state != State.CHASE:
		route_timer += delta
		if route_timer > MAX_ROUTE_TIME and not agent.is_navigation_finished():
			movement()
			route_timer = 0.0
	else:
		route_timer = 0.0

func handle_state_logic() -> void:
	match state:
		State.CHASE:
			if target_player:
				agent.target_position = target_player.global_position
		State.ALERT:
			animation_alert.play("alert")
			if agent.is_navigation_finished():
				alert_steps += 1
				if alert_steps < MAX_ALERT_STEPS:
					var offset := Vector2(randf_range(-100, 100), randf_range(-100, 100))
					agent.target_position = last_alert_position + offset
				else:
					set_state(State.IDLE)
		State.IDLE:
			animation_alert.stop()
			if agent.is_navigation_finished():
				movement()

func handle_movement(delta: float) -> void:
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

func update_vision_cone() -> void:
	vision_cone.global_position = global_position

func set_state(new_state: State) -> void:
	state = new_state
	emit_signal("state_changed", new_state)
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
	$RandomDir.start()

func hear_sound(sound_position: Vector2) -> void:
	if state != State.CHASE:
		interest_zones.append(sound_position)
		if state == State.IDLE:
			investigate_zone(sound_position)

func investigate_zone(pos: Vector2) -> void:
	set_state(State.ALERT)
	last_alert_position = pos
	alert_steps = 0
	agent.target_position = pos

func on_player_idle(pos: Vector2) -> void:
	silent_zone = pos
	silent_zone_weight = clamp(silent_zone_weight + 0.1, 0, MAX_WEIGHT)

func on_tree_chopped(pos: Vector2) -> void:
	print("Tree chopped near:", pos)
	hear_sound(pos)
	update_patrol_speed()

func update_patrol_speed() -> void:
	var remaining_trees := protected_trees.filter(func(t): return is_instance_valid(t)).size()
	var ratio = 1.0 - float(remaining_trees) / max(1, total_trees)

	WALK_SPEED = BASE_WALK_SPEED + lerp(0, 40.0, ratio)
	WALK_SPEED = clamp(WALK_SPEED, BASE_WALK_SPEED, MAX_SPEED - 10)


func _on_random_dir_timeout() -> void:
	$RandomDir.start()

func movement():
	if interest_zones.size() > 0:
		agent.target_position = interest_zones.pop_front()
	elif silent_zone_weight > 0.0 and randf() < silent_zone_weight:
		agent.target_position = silent_zone
		silent_zone_weight = max(silent_zone_weight - 0.1, 0)
	elif patrol_queue.size() > 0:
		var next_point = patrol_queue.pop_front()
		agent.target_position = next_point
	elif protected_trees.size() > 0:
		patrol_queue = patrol_points.duplicate()
		randomize_patrol_queue()
		movement()
	else:
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

func randomize_patrol_queue():
	patrol_queue.shuffle()
	

func _on_killzone_body_entered(body: Node2D) -> void:
	if body is Player:
		player.kill()
