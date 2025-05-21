extends Item

# ==============================================================================

func _use() -> void:
	if not Stage.has_current():
		return
	
	var cells := Stage.get_current().get_instance().get_cells().filter(func(c: CellData): return c.is_revealed())# and not c.aura is Sanctified)
	if cells.is_empty():
		return
	
	var cell: CellData = cells[randi() % cells.size()]
	
	#cell.aura = Aura.create(Sanctified)
	life_restore(cell.cell_value)
	#Effects.bury_bones(cell)
	
	clear()
