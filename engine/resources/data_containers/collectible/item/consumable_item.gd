@tool
@abstract
extends Item
class_name ConsumableItem

# ==============================================================================

func _post() -> void:
	clear()


func _can_use() -> bool:
	return true


func _get_texture_bg_color() -> Color:
	return 0x14a464ff
