@tool
extends CellObject
class_name Coin

# ==============================================================================
const ANIM_DURATION := 0.4
# ==============================================================================

func _get_texture() -> AnimatedTextureSequence:
	var texture := AnimatedTextureSequence.new()
	texture.atlas = preload("res://Assets/sprites/coin.png")
	texture.duration = ANIM_DURATION
	return texture


func _get_palette() -> CompressedTexture2D:
	return get_cell().get_theme_icon("coin_palette", "Cell")


func _get_animation_delta() -> float:
	return 0.1


func _interact() -> void:
	var value: int = Effects.get_coin_value(1, get_cell())
	get_stats().coins += value
	
	get_cell().add_text_particle("+" + str(value), TextParticles.ColorPreset.COINS)
	
	tween_texture_to(get_stage().get_statbar().get_coin_position())
	
	clear()


func _get_charitable_amount() -> int:
	return 1


func _is_charitable() -> bool:
	return true
