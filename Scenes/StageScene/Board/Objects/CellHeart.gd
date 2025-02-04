@tool
extends CellObject
class_name CellHeart

# ==============================================================================
const ANIM_DURATION := 0.7
const TEXTURE_WIDTH := 10
# ==============================================================================

func _get_texture() -> CompressedTexture2D:
	return preload("res://Assets/sprites/heart.png")


func _animate(time: float) -> void:
	if not get_cell():
		return
	
	get_cell().get_object_texture_rect().get_2d_anchor().scale = Vector2.ONE * (
		1 + (1 + sin(2 * PI * time / ANIM_DURATION)) / TEXTURE_WIDTH
	)


func _get_palette() -> Texture2D:
	return get_cell().get_theme_icon("heart_palette", "Cell")


func _reset() -> void:
	get_cell().get_object_texture_rect().get_2d_anchor().scale = Vector2.ONE


func _interact() -> void:
	if get_stats().life >= get_stats().max_life:
		Toasts.add_toast("You're already at max life!", null)
		return
	
	var life := Effects.get_heart_value()
	
	get_stats().life_restore(life, self)
	get_cell().add_text_particle("+" + str(life), TextParticles.ColorPreset.LIFE)
	tween_texture_to(get_stage().get_statbar().get_heart_position())
	clear()
