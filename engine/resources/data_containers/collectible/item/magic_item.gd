@tool
@abstract
extends Item
class_name MagicItem

# ==============================================================================

func _post() -> void:
	clear_mana()


func _can_use() -> bool:
	return is_charged()


func _get_texture_bg_color() -> Color:
	return 0x2a6eb0ff
