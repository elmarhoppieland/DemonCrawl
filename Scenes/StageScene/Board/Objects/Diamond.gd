@tool
extends CellObject
class_name Diamond

# ==============================================================================

func _get_texture() -> CompressedTexture2D:
	return preload("res://Assets/sprites/diamond.png")


func _interact() -> void:
	var value: int = Effects.get_diamond_value(5, get_cell())
	get_stats().coins += value
	
	get_cell().add_text_particle("+" + str(value), TextParticles.ColorPreset.COINS)
	
	tween_texture_to(GuiLayer.get_statbar().get_coin_position())
	
	clear()


func _get_charitable_amount() -> int:
	return 5


func _is_charitable() -> bool:
	return true
