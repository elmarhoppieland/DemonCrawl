extends Item

# ==============================================================================

func use() -> void:
	var target := await target_cell()
	if not target:
		return
	
	if not target.aura == "burning":
		return
	
	target.aura = ""
	Stats.change_life(+3, self)
	
	clear()
