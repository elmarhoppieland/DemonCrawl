@tool
extends MagicItem

# ==============================================================================

func _use() -> void:
	for cell in await target_cells(2):
		cell.glean()


func _can_use() -> bool:
	return super() and get_quest().has_current_stage()
