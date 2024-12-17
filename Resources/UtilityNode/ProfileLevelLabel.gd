@tool
extends Label
class_name ProfileLevelLabel

# ==============================================================================

func _enter_tree() -> void:
	text = (tr("LEVEL") if "%" in tr("LEVEL") else "Lv%d") % (XPBar.level + 1)
	
	if not label_settings:
		label_settings = LabelSettings.new()
	
	label_settings.font_color = Color.GRAY
	label_settings.font_size = 8
	label_settings.outline_color = Color.BLACK
	label_settings.outline_size = 3
