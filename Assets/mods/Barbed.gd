extends StageMod

# ==============================================================================

func damage() -> void:
	if get_tree().current_scene is Board:
		Stats.defense -= StagesOverview.selected_stage.min_power
