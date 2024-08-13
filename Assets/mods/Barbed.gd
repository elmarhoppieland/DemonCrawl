extends StageMod

# ==============================================================================

func damage() -> void:
	if get_tree().current_scene is Board:
		Stats.defense -= Quest.get_selected_stage().min_power
