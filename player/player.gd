extends CharacterBody2D
class_name Player

signal zona_peligro(pos: Vector2)
signal chased

@export var SPEED := 50.0
var frozen = false
var current_tree: BaseTree = null

var tiempo_inmovil := 0.0
var ultima_posicion := Vector2.ZERO
var inmovil := false

func _physics_process(delta):
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		chased.emit()

	# Movimiento
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	move_and_slide()

	# Inmovilidad
	if global_position.distance_to(ultima_posicion) < 2.0:
		tiempo_inmovil += delta
		if tiempo_inmovil > 5.0 and not inmovil:
			inmovil = true
			emit_signal("zona_peligro", global_position)
	else:
		tiempo_inmovil = 0.0
		inmovil = false
	ultima_posicion = global_position

	# Detección de árboles
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Enemy:
			frozen = true
		elif collider is BaseTree:
			current_tree = collider

	# Interacción
	if Input.is_action_just_pressed("hit") and current_tree:
		if current_tree.can_be_chopped(self):
			current_tree.interact(self)
			current_tree = null
