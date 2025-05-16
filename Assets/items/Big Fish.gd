extends Item

# ==============================================================================

func use() -> void:
	var target := await target_cell()
	if not target:
		return
	
	if not target.aura is Burning:
		return
	
	target.aura = null
	life_restore(3, self)
	
	clear()
