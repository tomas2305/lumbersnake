extends CharacterBody2D

@export var SPEED := 150.0
var ctrl_press_count := 0
const MAX_PRESS_COUNT := 5
var frozen = false

func _input(event):
	
	if event.is_action_pressed("ui_select"):
		var tree = get_colliding_tree()
		if tree:
			ctrl_press_count += 1
			
			if ctrl_press_count >= MAX_PRESS_COUNT:
				tree.get_parent().chop() 
				ctrl_press_count = 0


func _physics_process(delta):
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	move_and_slide()
	
	if not get_colliding_tree():
		ctrl_press_count = 0
	
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Enemy:
			frozen = true

func get_colliding_tree():
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider.is_in_group("trees"):
			return collider
	return null
