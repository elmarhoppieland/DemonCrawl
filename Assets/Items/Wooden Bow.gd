@tool
extends Item

# ==============================================================================

func _use() -> void:
	_target(await target_cell())


func _invoke() -> void:
	_target(get_stage_instance().get_cells().pick_random())


func _target(cell: CellData) -> void:
	cell.reveal()
	
	if cell.has_monster():
		cell.get_object().kill()
	else:
		clear()
