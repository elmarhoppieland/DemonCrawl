@tool
extends Item
class_name ItemFiller

# ==============================================================================

func _get_texture_bg_color() -> Color:
	return Color.TRANSPARENT


func _has_annotation_text() -> bool:
	return false


func get_annotation_text() -> String:
	return ""
