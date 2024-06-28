extends Item

# ==============================================================================

func use() -> void:
	Board.solve_cell()


func damage(amount: int, source: Object) -> int:
	if source is CellMonster:
		clear()
		source.clear()
		return amount - 1
	
	return amount
