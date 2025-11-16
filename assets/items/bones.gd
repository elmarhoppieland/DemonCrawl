@tool
extends ConsumableItem

# ==============================================================================

func _use() -> void:
	var cells := get_quest().get_current_stage().get_cells().filter(func(c: CellData): return c.is_visible() and not c.get_aura() is Sanctified)
	if cells.is_empty():
		return
	
	var cell: CellData = cells.pick_random()
	
	cell.apply_aura(Sanctified)
	life_restore(cell.value)
	EffectManager.propagate(get_quest().get_item_effects().item_used_on_cell, self, cell)
	
	clear()


func _can_use() -> bool:
	return super() and get_quest().has_current_stage()
