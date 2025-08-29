@tool
extends Item

# ==============================================================================

func use() -> void:
	var target := await target_cell()
	if not target:
		return
	
	if not target.get_aura() is Burning:
		return
	
	target.clear_aura()
	life_restore(3, self)
	
	clear()
