@tool
extends Item

# ==============================================================================

func _use() -> void:
	_process(await target_cell())


func _invoke() -> void:
	_process(get_board().get_cells().pick_random())


func _process(cell: Cell) -> void:
	if not cell.is_revealed():
		cell.open(true)
	
	if cell.get_object() is Monster:
		cell.get_object().kill()
	else:
		clear()
