@tool
extends Item

# ==============================================================================

func change_morality(morality: int) -> int:
	if morality >= get_attributes().morality:
		return get_attributes().morality
	
	life_lose(1)
	return morality
