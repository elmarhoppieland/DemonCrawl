@tool
extends Mastery
class_name Survivor

# ==============================================================================

func quest_start() -> void:
	if level < 1:
		return
	get_stats().max_life += 1


func stage_end(stage: Stage) -> void:
	if level < 2:
		return
	
	if get_stats().life < get_stats().max_life:
		get_stats().max_life += stage.min_power


func _ability() -> void:
	for i in get_stats().max_life - get_stats().life:
		Stage.get_current().get_board().solve_cell()
	
	get_stats().life = get_stats().max_life
