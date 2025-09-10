@tool
extends Mastery
class_name Survivor

# ==============================================================================

func _quest_start() -> void:
	if level < 1:
		return
	get_stats().max_life += 1


func _enable() -> void:
	get_quest().get_stage_effects().finish_pressed.connect(_stage_finish)


func _disable() -> void:
	get_quest().get_stage_effects().finish_pressed.disconnect(_stage_finish)


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
