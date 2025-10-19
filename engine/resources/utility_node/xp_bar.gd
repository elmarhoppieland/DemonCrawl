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
	
	if not Codex.xp_changed.is_connected(update):
		Codex.xp_changed.connect(update)
	update()

func update() -> void:
	max_value = Codex.get_next_level_xp()
	value = Codex.xp

static func _get_value(height: int) -> int:
	return Codex.xp * height / Codex.get_next_level_xp()
