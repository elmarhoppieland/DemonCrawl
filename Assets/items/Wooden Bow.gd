@tool
extends Item

# ==============================================================================

func _use() -> void:
	_process(await target_cell())


func _invoke() -> void:
	_process(get_stage_instance().get_cells().pick_random())


func _process(cell: CellData) -> void:
	if not cell.is_revealed():
		cell.open(true)
	
	if cell.has_monster():
		cell.get_object().kill()
	else:
		clear()
