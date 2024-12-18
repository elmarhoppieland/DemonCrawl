@tool
extends Item

# ==============================================================================

func use() -> void:
	if not Stage.has_current():
		return
	
	Stage.get_current().get_instance().solve_cell()
	
	clear()


func damage(amount: int, source: Object) -> int:
	if source is CellMonster:
		clear()
		source.kill()
		return amount - 1
	
	return amount
