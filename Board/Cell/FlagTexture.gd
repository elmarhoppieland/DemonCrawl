extends TextureRect
class_name FlagCellTexture

# ==============================================================================

func play_flag() -> void:
	const FLAG_ANIM_DURATION := 0.1
	
	texture = owner.get_theme_icon("flag", "Cell")
	
	create_tween().tween_property(get_parent(), "scale", Vector2.ONE, FLAG_ANIM_DURATION).from(Vector2.ZERO)
