extends enemy_movement
class_name Enemy


@export var player: Node2D 
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var detectionArea: Area2D = $DetectionArea
var playerDetected = false

func _ready() -> void:
	random_generation()

func _physics_process(delta: float) -> void:
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
	


func makepath() -> void:
	agent.target_position = player.global_position


func _on_timer_timeout() -> void:
	if playerDetected:
		makepath()
	
func _on_detection_area_body_entered(body: Node2D) -> void:
	if(body is Player):
		playerDetected = true
		$RandomDir.stop()


func _on_detection_area_body_exited(body: Node2D) -> void:
	if(body is Player):
		playerDetected = false
		$RandomDir.start()


func _on_random_dir_timeout() -> void:
	random_generation()
	$RandomDir.start()
	
