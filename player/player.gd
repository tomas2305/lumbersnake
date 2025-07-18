extends CharacterBody2D
class_name Player

signal zona_peligro(pos: Vector2)
signal chased
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var walk_particles: CPUParticles2D = $WalkParticles
@export var SPEED := 50.0
@export var camera: Camera2D
@onready var enemy = get_tree().get_first_node_in_group("enemy")

var frozen = false
var current_tree: BaseTree = null

var tiempo_inmovil := 0.0
var ultima_posicion := Vector2.ZERO
var inmovil := false
var golpeando = false
var found_tree = null
var is_hidden := false
var look_dir := Vector2.DOWN

func _ready():
	await get_tree().process_frame
	_connect_bushes()
	_connect_enemy()
	anim.play("idle_down")
	anim.connect("animation_finished", Callable(self, "_on_anim_finished"))

func _physics_process(delta):
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		chased.emit()
		return

	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	move_and_slide()

	if not golpeando:
		if direction.length() > 0.1:
			look_dir = direction
			_update_walk_animation(direction)
		else:
			_update_idle_animation(look_dir)

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

	# Interacción
	if Input.is_action_just_pressed("hit"):
		if current_tree:
			_play_hit_animation()
			if !Music.esta_muted:
				$Axe.play(0.3)
			current_tree.interact(self)
		elif direction.length() == 0.0:
			_play_hit_animation()

func _update_walk_animation(dir: Vector2) -> void:
	walk_particles.emitting = true
	if abs(dir.y) > abs(dir.x):
		if dir.y < 0:
			anim.play("walk_up")
		else:
			anim.play("walk_down")
	else:
		anim.play("walk_x")
		if dir.x < 0 and !anim.flip_h:
			anim.flip_h = true
		elif dir.x > 0 and anim.flip_h:
			anim.flip_h = false

func _update_idle_animation(dir: Vector2) -> void:
	walk_particles.emitting = false
	if abs(dir.y) > abs(dir.x):
		if dir.y < 0:
			anim.play("idle_up")
		else:
			anim.play("idle_down")
	else:
		anim.play("idle_x")
		if dir.x < 0 and !anim.flip_h:
			anim.flip_h = true
		elif dir.x > 0 and anim.flip_h:
			anim.flip_h = false

func _on_anim_finished():
	if golpeando:
		golpeando = false
		_update_idle_animation(look_dir)

func _play_hit_animation(_unused: Vector2 = Vector2.ZERO) -> void:
	golpeando = true
	anim.frame = 0

	if abs(look_dir.y) > abs(look_dir.x):
		if look_dir.y < 0:
			anim.play("hit_up")
		else:
			anim.play("hit_down")
	else:
		anim.play("hit_x")
		anim.flip_h = look_dir.x < 0


func _on_bush_player_entered_bush(body: Node2D) -> void:
	if body == self:
		is_hidden = true
		anim.modulate.a = 0.4

func _on_bush_player_exited_bush(body: Node2D) -> void:
	if body == self:
		is_hidden = false
		anim.modulate.a = 1.0

func _connect_bushes():
	for bush in get_tree().get_nodes_in_group("bushes"):
		bush.connect("player_entered_bush", Callable(self, "_on_bush_player_entered_bush"))
		bush.connect("player_exited_bush", Callable(self, "_on_bush_player_exited_bush"))
		
		
func _connect_enemy():
	if enemy != null:
		enemy.connect("state_changed", Callable(self, "_on_enemy_state_changed"))
	
	
func _on_enemy_state_changed(state: Enemy.State):
	print(state)
	if state == Enemy.State.CHASE:
		camera.zoom_out()
	elif camera.zoom != camera.zoom_default:
		camera.set_zoom_default()

func set_tree(tree : BaseTree):
	current_tree = tree

func kill():
	frozen = true
	emit_signal("chased")
