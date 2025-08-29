@tool
extends Book

# ==============================================================================

func _activate() -> void:
	var monsters := get_stage_instance().get_cells().filter(func(cell: CellData) -> bool:
		return cell.has_monster()
	)
	
	if monsters.is_empty():
		return
	
	var cell := monsters.pick_random() as CellData
	
	if cell.is_hidden():
		cell.open(true)
	
	cell.get_object().kill()
