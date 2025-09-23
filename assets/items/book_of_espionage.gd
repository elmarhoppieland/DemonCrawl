@tool
extends Book

# ==============================================================================

func _activate() -> void:
	var cells := get_stage_instance().get_cells().filter(func(cell: CellData) -> bool:
		return cell.is_hidden()
	)
	if cells.is_empty():
		return
	
	var cell: CellData = cells.pick_random()
	cell.glean()
