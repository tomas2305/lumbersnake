extends CharacterBody2D
class_name Player

@export var SPEED := 50.0
var frozen = false
var current_tree: BaseTree = null

func _physics_process(delta):
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	move_and_slide()

	# Detectar colisiones con árboles y guardar referencia
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Enemy:
			frozen = true
		elif collider is BaseTree:
			current_tree = collider

	# Interacción directa y precisa
	if Input.is_action_just_pressed("ui_select") and current_tree:
		if current_tree.can_be_chopped(self):
			current_tree.interact(self)
			current_tree = null
