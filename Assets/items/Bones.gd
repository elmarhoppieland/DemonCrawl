extends Item

# ==============================================================================

func _use() -> void:
	if not StageInstance.has_current():
		return
	
	var cells := StageInstance.get_current().get_cells().filter(func(c: CellData): return c.is_visible())# and not c.aura is Sanctified)
	if cells.is_empty():
		return
	
	var cell: CellData = cells[randi() % cells.size()]
	
	#cell.aura = Sanctified.new()
	life_restore(cell.cell_value)
	#Effects.bury_bones(cell)
	
	clear()
