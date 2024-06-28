extends Item

# ==============================================================================

func use() -> void:
	Stats.change_life(+1, self)
