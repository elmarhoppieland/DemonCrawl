extends Item

# ==============================================================================

func use() -> void:
	if not Board.exists():
		return
	
	Board.solve_cell()
	
	clear()


func damage(amount: int, source: Object) -> int:
	if source is CellMonster:
		clear()
		source.kill()
		return amount - 1
	
	return amount
