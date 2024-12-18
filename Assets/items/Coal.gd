@tool
extends Item

# ==============================================================================

func change_morality(morality: int) -> int:
	if morality >= get_quest_instance().morality:
		return get_quest_instance().morality
	
	life_lose(1)
	return morality
