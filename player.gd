extends CharacterBody2D

@export var SPEED := 150.0
var ctrl_press_count := 0
const MAX_PRESS_COUNT := 5
var frozen = false
@export var tilemap: TileMapLayer
var current_interactive_cell: Vector2i = Vector2i(-1, -1)
var current_type: String = ""
var carrying_rock := false

func _input(event):
	if event.is_action_pressed("ui_select"):
		var result = get_colliding_tile()
		if result.cell != Vector2i(-1, -1):
			if result.cell == current_interactive_cell and result.type == current_type:
				ctrl_press_count += 1
			else:
				current_interactive_cell = result.cell
				current_type = result.type
				ctrl_press_count = 1
			if ctrl_press_count >= MAX_PRESS_COUNT:
				match result.type:
					"tree":
						chop_tree(result.cell)
					_: 
						print("No action for type:", result.type)
				
				ctrl_press_count = 0
				current_interactive_cell = Vector2i(-1, -1)
				current_type = ""

func _physics_process(delta):
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	move_and_slide()

	if get_colliding_tile().cell == Vector2i(-1, -1):
		ctrl_press_count = 0
		current_interactive_cell = Vector2i(-1, -1)
		current_type = ""

	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Enemy:
			frozen = true

# Devuelve la celda interactiva y el tipo detectado
func get_colliding_tile() -> Dictionary:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == tilemap:
			var local_pos = tilemap.to_local(collision.get_position())
			var cell = tilemap.local_to_map(local_pos)
			var tile_data = tilemap.get_cell_tile_data(cell)
			if tile_data and tile_data.has_custom_data("type"):
				return { "cell": cell, "type": tile_data.get_custom_data("type") }
	return { "cell": Vector2i(-1, -1), "type": "" }

func chop_tree(cell: Vector2i):
	var tile_data = tilemap.get_cell_tile_data(cell)
	if not tile_data: return
	if not tile_data.has_custom_data("tree_origin_offset"): return
	
	var offset = tile_data.get_custom_data("tree_origin_offset") as Vector2i
	if offset == Vector2i(0, 0): return

	var tree_origin = cell + offset
	erase_tree_area(tree_origin)

#func mine_rock(cell: Vector2i):
#	tilemap.set_cell(cell,6,Vector2i(0,0))


func erase_tree_area(origin: Vector2i):
	for y in range(5):
		for x in range(4):
			var pos = origin + Vector2i(x, y)
			tilemap.set_cell(pos,6,Vector2i(0,0))
