extends StageMod

# ==============================================================================

func damage() -> void:
	var tree = get_tree()
	if tree != null and tree.current_scene is Board:
		Stats.defense -= StagesOverview.selected_stage.min_power
