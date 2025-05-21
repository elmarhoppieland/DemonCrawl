@tool
extends Item

# ==============================================================================

func _use() -> void:
	_process(await target_cell())


func _invoke() -> void:
	_process(Stage.get_current().get_instance().get_cells().pick_random())


func _process(cell: CellData) -> void:
	if not cell.is_revealed():
		cell.open(true)
	
	if cell.object is Monster:
		cell.object.kill()
	else:
		clear()
