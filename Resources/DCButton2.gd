extends Button
class_name DCButton2

# ==============================================================================

func _ready() -> void:
	const ANIM_DURATION := 0.1
	
	get_child(0).modulate.a = 0
	
	mouse_entered.connect(func():
		create_tween().tween_property(get_child(0), "modulate:a", 1.0, ANIM_DURATION).from(0.0)
	)
	mouse_exited.connect(func():
		create_tween().tween_property(get_child(0), "modulate:a", 0.0, ANIM_DURATION).from(1.0)
	)
