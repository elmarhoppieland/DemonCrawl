@tool
extends Label
class_name ProfileLevelLabel

# ==============================================================================

func _enter_tree() -> void:
	text = tr("generic.level.abbr")
	if "%" in text:
		text %= XPBar.level
	else:
		text += "." + str(XPBar.level)
	
	if not label_settings:
		label_settings = LabelSettings.new()
	
	label_settings.font_color = Color.GRAY
	label_settings.font_size = 8
	label_settings.outline_color = Color.BLACK
	label_settings.outline_size = 3
