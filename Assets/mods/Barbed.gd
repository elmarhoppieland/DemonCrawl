extends StageMod

# ==============================================================================

func damage(_amount: int) -> void:
	if get_tree().current_scene is Board:
		Stats.defense -= StagesOverview.selected_stage.min_power
