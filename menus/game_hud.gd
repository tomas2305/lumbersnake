extends CanvasLayer

@onready var enemy_state_hud: AnimatedSprite2D = $HUD/EnemyStateHUD
@onready var curse_bar: TextureProgressBar = $HUD/CurseBar

func _on_enemy_state_changed(new_state: Variant) -> void:
	match new_state:
		Enemy.State.IDLE:
			enemy_state_hud.play("idle")
		Enemy.State.ALERT:
			enemy_state_hud.play("alert")
		Enemy.State.CHASE:
			enemy_state_hud.play("chase")

func restore_time():
	var tween = get_tree().create_tween()
	tween.tween_property(curse_bar, "value", curse_bar.min_value, 1.2)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(curse_bar, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.3)
	tween.tween_property(curse_bar, "modulate", Color(1, 1, 1, 1), 0.6)\
		 .set_delay(0.3)

func set_curse_bar(value : Variant):
	curse_bar.value = value

func set_curse_timer(curse_duration : float):
	curse_bar.min_value = 0
	curse_bar.max_value = curse_duration
	curse_bar.value = curse_duration  
