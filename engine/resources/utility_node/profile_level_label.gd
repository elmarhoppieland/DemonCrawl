@tool
extends Label
class_name ProfileLevelLabel

# ==============================================================================

func _enter_tree() -> void:
	if not label_settings:
		label_settings = LabelSettings.new()
	
	label_settings.font_color = Color.GRAY
	label_settings.font_size = 8
	label_settings.outline_color = Color.BLACK
	label_settings.outline_size = 3
	
	if not Eternity.loaded.is_connected(update):
		Eternity.loaded.connect(update)
		Eternity.saved.connect(update)
	update(null)

func update(_arg):
	text = tr("generic.level.abbr")
	if "%" in text:
		text %= Codex.level
	else:
		text += "." + str(Codex.level)
