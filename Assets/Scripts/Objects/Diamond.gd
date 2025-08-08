@tool
extends CellObject
class_name Diamond

# ==============================================================================

func _get_texture() -> CompressedTexture2D:
	return preload("res://Assets/Sprites/diamond.png")


func _interact() -> void:
	var value: int = EffectManager.propagate(get_quest().get_stage_effects().get_object_value, [self, 5, &"coins"], 1)
	get_stats().coins += value
	
	get_cell().add_text_particle("+" + str(value), TextParticles.ColorPreset.COINS)
	
	tween_texture_to(GuiLayer.get_statbar().get_coin_position())
	
	clear()


func _get_charitable_amount() -> int:
	return 5


func _is_charitable() -> bool:
	return true
