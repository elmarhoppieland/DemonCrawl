@tool
extends Loot
class_name Diamond

# ==============================================================================

func _get_texture() -> CompressedTexture2D:
	return preload("res://Assets/Sprites/diamond.png")


func _collect() -> bool:
	var value := get_value(5, &"coins")
	get_stats().coins += value
	
	get_cell().add_text_particle("+" + str(value), TextParticles.ColorPreset.COINS)
	
	tween_texture_to(GuiLayer.get_statbar().get_coin_position())
	
	clear()
	
	return true


func _get_charitable_amount() -> int:
	return 5


func _is_charitable() -> bool:
	return true


func _can_interact() -> bool:
	return true
