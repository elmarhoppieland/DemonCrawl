extends Item

# ==============================================================================

func change_morality(morality: int) -> int:
	if morality >= PlayerStats.morality:
		return PlayerStats.morality
	
	Stats.change_life(-1, self)
	return morality
