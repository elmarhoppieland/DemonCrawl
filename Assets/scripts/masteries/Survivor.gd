@tool
extends Mastery
class_name Survivor

# ==============================================================================

func _quest_start() -> void:
	if level < 1:
		return
	get_stats().max_life += 1


func _quest_load() -> void:
	Promise.dynamic_signal(get_quest().get_current_stage, "finish_pressed", get_quest().current_stage_changed).connect(_stage_finish)


func _stage_finish() -> void:
	if level < 2:
		return
	
	if get_stats().life < get_stats().max_life:
		get_stats().max_life += get_quest().get_current_stage().get_stage().min_power


func _ability() -> void:
	var missing_life := get_stats().max_life - get_stats().life
	
	if get_quest().has_current_stage():
		for i in missing_life:
			get_quest().get_current_stage().solve_cell()
	
	get_stats().life_restore(missing_life, self)


func _get_max_charges() -> int:
	return 3
