extends Sprite2D

# ==============================================================================

func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y, MainMenu.TOTAL_ANIM_DURATION).from(position.y + 20)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	while tween.is_running():
		await get_tree().process_frame
		if Input.is_action_just_pressed("interact"):
			tween.set_speed_scale(INF)
