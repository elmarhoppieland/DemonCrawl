extends Button
class_name DCButton2

# ==============================================================================

func _ready() -> void:
	const ANIM_DURATION := 0.1
	
	get_child(0).modulate.a = 0
	
	mouse_entered.connect(func():
		var tween := create_tween()
		tween.tween_property(get_child(0), "modulate:a", 1.0, ANIM_DURATION).from(0.0)
		tween.parallel().tween_method(func(color):
			add_theme_color_override("font_hover_color", color)
		, Color.WHITE, Color.BLACK, ANIM_DURATION)
	)
	mouse_exited.connect(func():
		var tween := create_tween()
		tween.tween_property(get_child(0), "modulate:a", 0.0, ANIM_DURATION).from(1.0)
		tween.parallel().tween_method(func(color: Color):
			add_theme_color_override("font_color", color)
		, Color.BLACK, Color.WHITE, ANIM_DURATION)
	)
