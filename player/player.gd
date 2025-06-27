extends CharacterBody2D
class_name Player

signal zona_peligro(pos: Vector2)
signal chased
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var SPEED := 50.0
var frozen = false
var current_tree: BaseTree = null

var tiempo_inmovil := 0.0
var ultima_posicion := Vector2.ZERO
var inmovil := false
var golpeando = false
var found_tree = null
var is_hidden := false
var look_dir := Vector2.DOWN  # Dirección actual de mirada

func _ready():
	await get_tree().process_frame
	_connect_bushes()
	anim.play("idle_down")
	anim.connect("animation_finished", Callable(self, "_on_anim_finished"))

func _physics_process(delta):
	
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		chased.emit()
		return
	
	# Movimiento
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	move_and_slide()

	if not golpeando:
		if direction != Vector2.ZERO:
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


	var sigue_colisionando_con_arbol := false
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Enemy:
			frozen = true
		elif collider is BaseTree:
			current_tree = collider
			sigue_colisionando_con_arbol = true

# Si antes había un árbol y ya no colisionás con él, lo borramos
	if current_tree and not sigue_colisionando_con_arbol:
		current_tree = null

	# Interacción
	if Input.is_action_just_pressed("hit") and current_tree:
		_play_hit_animation(direction)
		if current_tree.can_be_chopped(self):
			if !Music.esta_muted:
				$Axe.play(0.3)
			current_tree.interact(self)
			current_tree = null
			
	if current_tree and global_position.distance_to(current_tree.global_position) > 16:
		current_tree = null

func _update_walk_animation(dir: Vector2) -> void:
	if dir.y < 0:
		anim.play("walk_up")
	elif dir.y > 0:
		anim.play("walk_down")
	else:
		anim.play("walk_x")
		anim.flip_h = dir.x < 0

func _update_idle_animation(dir: Vector2) -> void:
	if dir.y < 0:
		anim.play("idle_up")
	elif dir.y > 0:
		anim.play("idle_down")
	else:
		anim.play("idle_x")
		anim.flip_h = dir.x < 0

func _on_anim_finished():
	if golpeando:
		golpeando = false
		_update_idle_animation(look_dir)
		
func _play_hit_animation(dir: Vector2) -> void:
	golpeando = true
	anim.frame = 0  # Reinicia desde el inicio

	if dir.y < 0:
		anim.play("hit_up")
		print("played hit up")
	elif dir.y > 0:
		anim.play("hit_down")
		print("played hit down")
	else:
		anim.play("hit_x")
		print("played hit x")
		anim.flip_h = dir.x < 0

func _on_bush_player_entered_bush(body: Node2D) -> void:
	if body == self:
		is_hidden = true
		anim.modulate.a = 0.8
		print("Entered bush")

func _on_bush_player_exited_bush(body: Node2D) -> void:
	if body == self:
		is_hidden = false
		anim.modulate.a = 1.0

func _connect_bushes():
	for bush in get_tree().get_nodes_in_group("bushes"):
		print("Conectando con:", bush.name)
		bush.connect("player_entered_bush", Callable(self, "_on_bush_player_entered_bush"))
		bush.connect("player_exited_bush", Callable(self, "_on_bush_player_exited_bush"))
