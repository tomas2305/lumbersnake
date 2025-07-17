extends StaticBody2D
class_name BaseTree

signal sound_emitted(origin: Vector2)
@onready var chopped_sound: AudioStreamPlayer = $ChoppedSound
@onready var camera: Camera2D = get_tree().get_first_node_in_group("camera")

@export var min_hits := 10
@export var max_hits := 20

@onready var chop_area: Area2D = $ChopArea
@onready var tree_hit_particle: CPUParticles2D = $TreeHitParticle
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var required_hits := 0
var current_hits := 0
var player_in_area := false
var player_ref: Player = null
var dead = false
var returning_to_focus_after_hit = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	required_hits = randi_range(min_hits, max_hits)
	chop_area.body_entered.connect(_on_body_entered)
	chop_area.body_exited.connect(_on_body_exited)
	animated_sprite_2d.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_body_entered(body: Node) -> void:
	if body is Player and not dead:
		player_in_area = true
		player_ref = body
		animated_sprite_2d.play("focus")
		print("Jugador en el área del árbol")
		body.set_tree(self)

func _on_body_exited(body: Node) -> void:
	if body is Player and not dead:
		player_in_area = false
		player_ref = null
		animated_sprite_2d.play("idle")
		body.set_tree(null)

func interact(by: Player):
	if dead:
		return

	current_hits += 1
	print("Golpe recibido:", current_hits, "/", required_hits)

	emit_signal("sound_emitted", global_position)
	animated_sprite_2d.play("hit")
	tree_hit_particle.emitting = true
	returning_to_focus_after_hit = true

	if camera.has_method("trigger_shake"):
		camera.trigger_shake()

	emit_sound()

	if current_hits >= required_hits:
		if !Music.esta_muted:
			$ChoppedSound.play()
		Global.arboles_destuidos += 1
		dead = true
		animation_player.play("kill_tree")
		

func emit_sound():
	var bodies = $SoundArea.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("hear_sound"):
			body.hear_sound(global_position)

func _on_animation_finished():
	if returning_to_focus_after_hit and animated_sprite_2d.animation == "hit":
		animated_sprite_2d.play("focus")
		returning_to_focus_after_hit = false

func kill():
	queue_free()
