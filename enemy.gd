extends CharacterBody2D
class_name Enemy

@export var SPEED := 80.0
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var player: Node2D = $"../Player"

func _ready() -> void:
	agent.target_position = player.global_position
	agent.path_desired_distance = 4.0
	agent.target_desired_distance = 4.0
	agent.avoidance_enabled = true
	agent.radius = 4.0

func _physics_process(delta: float) -> void:
	agent.target_position = player.global_position

	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next = agent.get_next_path_position()
		var dir = (next - global_position).normalized()
		velocity = dir * SPEED

	move_and_slide()

#extends CharacterBody2D
#
#@export var speed: float = 80.0
#@onready var player = $"../Player"
#@onready var ray = $RayToPlayer
#
#func _physics_process(_delta: float) -> void:
	#if not player:
		#return
#
	## Dirección hacia el jugador
	#var dir = (player.global_position - global_position).normalized()
#
	## Apuntamos el raycast hacia esa dirección
	#ray.target_position = dir * 32
	#ray.force_raycast_update()
#
	## Si hay colisión, intentamos moverse por los lados
	#if ray.is_colliding():
		#var side_dirs = [
			#dir.rotated(deg_to_rad(45)),
			#dir.rotated(deg_to_rad(-45)),
			#dir.rotated(deg_to_rad(90)),
			#dir.rotated(deg_to_rad(-90)),
		#]
		#for alt in side_dirs:
			#ray.target_position = alt * 32
			#ray.force_raycast_update()
			#if not ray.is_colliding():
				#dir = alt
				#break
#
	## Movimiento
	#velocity = dir * speed
	#move_and_slide()

#extends CharacterBody2D
#
#@export var SPEED := 60.0
#@onready var player: CharacterBody2D = $"../Player"
#
#func _physics_process(delta: float) -> void:
	#if player:
		#var delta_pos = player.global_position - global_position
		#var direction := Vector2.ZERO
#
		## Elegí el eje con mayor distancia para evitar movimiento diagonal
		#if abs(delta_pos.x) > abs(delta_pos.y):
			#direction.x = sign(delta_pos.x)
		#else:
			#direction.y = sign(delta_pos.y)
#
		#velocity = direction * SPEED
		#move_and_slide()
