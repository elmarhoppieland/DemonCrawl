@tool
extends Mastery
class_name Survivor

# ==============================================================================

func _quest_start() -> void:
	if level < 1:
		return
	get_stats().max_life += 1


func _quest_load() -> void:
	Promise.dynamic_signal(Stage.get_current, "finish_pressed", Stage.current_changed).connect(_stage_finish)
	#Effects.Signals.stage_leave.connect(_stage_leave)


func _stage_finish() -> void:
	if level < 2:
		return
	
	if get_stats().life < get_stats().max_life:
		get_stats().max_life += Stage.get_current().min_power


func _ability() -> void:
	var missing_life := get_stats().max_life - get_stats().life
	
	if Stage.has_current() and Stage.get_current().has_instance():
		for i in missing_life:
			Stage.get_current().get_instance().solve_cell()
	
	get_stats().life_restore(missing_life, self)


func _get_max_charges() -> int:
	return 3
