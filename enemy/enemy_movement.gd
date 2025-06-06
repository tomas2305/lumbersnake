extends CharacterBody2D
class_name enemy_movement
@export var speed = 60
var current_states = enemy_states.MOVEDOWN
enum enemy_states {
	MOVERIGHT,
	MOVELEFT,
	MOVEUP,
	MOVEDOWN,
	MOVEUP_RIGHT,
	MOVEUP_LEFT,
	MOVEDOWN_RIGHT,
	MOVEDOWN_LEFT
}
var dir

func movement() -> void:
	
	match current_states:
		enemy_states.MOVERIGHT:
			move_right()
		enemy_states.MOVELEFT:
			move_left()
		enemy_states.MOVEUP:
			move_up()
		enemy_states.MOVEDOWN:
			move_down()
		enemy_states.MOVEDOWN_RIGHT:
			move_down_right()
		enemy_states.MOVEDOWN_LEFT:
			move_down_left()
		enemy_states.MOVEUP_RIGHT:
			move_up_right()
		enemy_states.MOVEUP_LEFT:
			move_up_left()

func random_generation():
	dir = randi() % 8
	random_direction()

func random_direction():
	match dir:
		0:
			current_states = enemy_states.MOVERIGHT
		1:
			current_states = enemy_states.MOVELEFT
		2:
			current_states = enemy_states.MOVEUP
		3:
			current_states = enemy_states.MOVEDOWN
		4:
			current_states = enemy_states.MOVEDOWN_RIGHT
		5:
			current_states = enemy_states.MOVEDOWN_LEFT
		6:
			current_states = enemy_states.MOVEUP_RIGHT
		7:
			current_states = enemy_states.MOVEUP_LEFT

func move_right():
	velocity = Vector2.RIGHT * speed


func move_left():
	velocity = Vector2.LEFT * speed

func move_up():
	velocity = Vector2.UP * speed
	
func move_down():
	velocity = Vector2.DOWN * speed
	
func move_up_right():
	velocity = (Vector2.UP + Vector2.RIGHT).normalized() * speed

func move_up_left():
	velocity = (Vector2.UP + Vector2.LEFT).normalized() * speed

func move_down_right():
	velocity = (Vector2.DOWN + Vector2.RIGHT).normalized() * speed

func move_down_left():
	velocity = (Vector2.DOWN + Vector2.LEFT).normalized() * speed
