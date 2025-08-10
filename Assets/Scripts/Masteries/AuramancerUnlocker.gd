extends MasteryUnlocker
class_name AuramancerUnlocker

# ==============================================================================

func _enter_tree() -> void:
	get_quest().get_stage_effects().completed.connect(_stage_completed)


func _exit_tree() -> void:
	get_quest().get_stage_effects().completed.disconnect(_stage_completed)


func _stage_completed() -> void:
	var auras: Array[Script] = []
	for cell in get_quest().get_current_stage().get_cells():
		if cell.has_aura():
			var aura: Script = cell.get_aura().get_script()
			if aura not in auras:
				auras.append(aura)
				if auras.size() >= 10:
					break
	
	if auras.size() >= 1:
		unlock(1)
	if auras.size() >= 5:
		unlock(2)
	if auras.size() >= 10:
		unlock(3)
