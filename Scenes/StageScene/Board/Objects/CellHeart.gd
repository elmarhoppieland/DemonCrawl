@tool
extends CellObject
class_name CellHeart

# ==============================================================================

func _get_texture() -> CompressedTexture2D:
	return preload("res://Assets/sprites/heart.png")


func _animate(time: float) -> void:
	const ANIM_DURATION := 0.7
	const TEXTURE_WIDTH := 10
	
	get_cell().get_object_texture_rect().get_2d_anchor().scale = Vector2.ONE * (
		1 + (1 + sin(2 * PI * time / ANIM_DURATION)) / TEXTURE_WIDTH
	)


func _get_palette() -> CompressedTexture2D:
	return get_cell().get_theme_icon("heart_palette", "Cell")
