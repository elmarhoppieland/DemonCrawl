extends Item

# ==============================================================================

func use() -> void:
	var cells := Board.get_cells().filter(func(c: Cell): return c.revealed and c.aura != "sanctified")
	if cells.is_empty():
		return
	
	var cell: Cell = cells[RNG.randi() % cells.size()]
	
	cell.aura = "sanctified"
	Stats.change_life(+cell.cell_value, self)
	EffectManager.propagate_call("bury_bones", [cell])
	
	clear()
