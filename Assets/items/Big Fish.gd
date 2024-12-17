extends Item

# ==============================================================================

func use() -> void:
	var target := await target_cell()
	if not target:
		return
	
	if not target.aura == "burning":
		return
	
	target.aura = ""
	life_restore(3, self)
	
	clear()
