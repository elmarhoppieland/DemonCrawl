@tool
extends ProgressBar
class_name XPBar

# ==============================================================================

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	fill_mode = FILL_BOTTOM_TO_TOP
	show_percentage = false
	
	custom_minimum_size.y = 16
	
	if not Eternity.loaded.is_connected(update):
		Eternity.loaded.connect(update)
		Eternity.saved.connect(update)
	update(null)

func update(_arg) -> void:
	max_value = Codex.get_next_level_xp()
	value = Codex.xp

static func _get_value(height: int) -> int:
	return Codex.xp * height / Codex.get_next_level_xp()
