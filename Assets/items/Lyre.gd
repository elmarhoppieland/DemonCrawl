extends Item

# ==============================================================================

func use() -> void:
	if not get_tree().current_scene is StageSelect:
		return
	
	StagesOverview.selected_stage.monsters -= 5
	
	clear_mana()
