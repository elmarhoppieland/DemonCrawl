extends Item

# ==============================================================================

func use() -> void:
	if not Stage.has_current():
		return
	
	var cells := Stage.get_current().get_instance().get_cells().filter(func(c: CellData): return c.is_revealed() and c.aura != "sanctified")
	if cells.is_empty():
		return
	
	var cell: Cell = cells[randi() % cells.size()]
	
	cell.aura = "sanctified"
	life_restore(cell.cell_value)
	Effects.bury_bones(cell)
	
	clear()
