extends CanvasLayer

@onready var enemy_state_hud: AnimatedSprite2D = $HUD/EnemyStateHUD

func _on_enemy_state_changed(new_state: Variant) -> void:
	match new_state:
		Enemy.State.IDLE:
			enemy_state_hud.play("idle")
		Enemy.State.ALERT:
			enemy_state_hud.play("alert")
		Enemy.State.CHASE:
			enemy_state_hud.play("chase")
