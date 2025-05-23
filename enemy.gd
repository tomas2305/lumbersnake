extends CharacterBody2D
class_name Enemy

@export var SPEED := 80
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@export var player: Node2D 

func _ready() -> void:
	makepath()

func _physics_process(delta: float) -> void:
	
	var next = agent.get_next_path_position()
	if global_position.distance_to(next) < 1000.0:  # puedes ajustar el umbral
		velocity = Vector2.ZERO
	var dir = (next - global_position).normalized()
	velocity = dir * SPEED
	move_and_slide()
	


func makepath() -> void:
	agent.target_position = player.global_position


func _on_timer_timeout() -> void:
	makepath()

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
