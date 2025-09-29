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
	
	cell.reveal()
	cell.get_object().kill()
