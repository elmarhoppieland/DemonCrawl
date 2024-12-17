extends Mastery

# ==============================================================================

func quest_start() -> void:
	if level < 1:
		return
	get_quest_instance().max_life += 1


func stage_end(stage: Stage) -> void:
	if level < 2:
		return
	
	if get_quest_instance().life < get_quest_instance().max_life:
		get_quest_instance().max_life += stage.min_power


func _ability() -> void:
	for i in get_quest_instance().max_life - get_quest_instance().life:
		Stage.get_current().get_board().solve_cell()
	
	get_quest_instance().life = get_quest_instance().max_life
