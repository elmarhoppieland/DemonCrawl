@tool
@abstract
extends Item
class_name OmenItem

# ==============================================================================

func _get_texture_bg_color() -> Color:
	return 0xbc3838ff


func notify_lost() -> void:
	super()
	
	get_attributes().omens_destroyed += 1
