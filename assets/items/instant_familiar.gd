@tool
extends ConsumableItem

# ==============================================================================

func _use() -> void:
	for cell in await target_cell():
		if cell.is_empty() and cell.is_visible():
			cell.spawn(Familiar)
	
	if not is_use_cancelled():
		get_quest().pass_turn()


func _invoke() -> void:
	for cell in target_random(1, func(cell: CellData) -> bool: return cell.is_visible() and cell.is_empty()):
		cell.spawn(Familiar)
	
	get_quest().pass_turn()


func _can_use() -> bool:
	return super() and get_quest().has_current_stage()
