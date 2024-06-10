@tool
extends ProgressBar
class_name XPBar

# ==============================================================================
static var xp: int = SavesManager.get_value("xp", XPBar, 40) :
	set(new_xp):
		xp = new_xp
		
		while xp > get_next_level_xp():
			xp -= get_next_level_xp()
			level += 1
static var level: int = SavesManager.get_value("level", XPBar, 0)
# ==============================================================================

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		return
	
	await get_tree().process_frame
	max_value = XPBar.get_next_level_xp()
	value = xp
	
	fill_mode = FILL_BOTTOM_TO_TOP
	show_percentage = false
	
	custom_minimum_size.y = 16


# TODO
static func get_next_level_xp() -> int:
	return 100


static func _get_value(height: int) -> int:
	return XPBar.xp * height / get_next_level_xp()
