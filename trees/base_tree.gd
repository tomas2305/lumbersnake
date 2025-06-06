extends StaticBody2D
class_name BaseTree

signal chopped
signal sound_emitted(origin: Vector2)

@export var min_hits := 3
@export var max_hits := 6

var required_hits := 0
var current_hits := 0
var player_in_area := false
var player_ref: Player = null

func _ready() -> void:
	required_hits = randi_range(min_hits, max_hits)
	$ChopArea.body_entered.connect(_on_body_entered)
	$ChopArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_in_area = true
		player_ref = body
		print("Jugador en el área del árbol")

func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_in_area = false
		player_ref = null

func can_be_chopped(by: Player) -> bool:
	return player_in_area and player_ref == by

func interact(by: Player):
	if not can_be_chopped(by):
		return

	current_hits += 1
	print("Golpe recibido:", current_hits, "/", required_hits)

	emit_signal("sound_emitted", global_position)
	emit_sound()

	if current_hits >= required_hits:
		emit_signal("chopped")
		Global.arboles_destuidos += 1
		queue_free()

func emit_sound():
	var bodies = $SoundArea.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("hear_sound"):
			body.hear_sound(global_position)
