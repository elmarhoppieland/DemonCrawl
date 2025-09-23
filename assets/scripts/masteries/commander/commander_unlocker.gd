@tool
extends MasteryUnlocker

# ==============================================================================

func _enter_tree() -> void:
	get_quest().get_object_effects().spawned.connect(_object_spawned)


func _exit_tree() -> void:
	get_quest().get_object_effects().spawned.disconnect(_object_spawned)


func _object_spawned(object: CellObject) -> void:
	if object is not Familiar:
		return
	
	var familiar_count := 0
	for cell in object.get_stage_instance().get_cells():
		if cell.get_object() is Familiar:
			familiar_count += 1
	
	if familiar_count >= 10:
		unlock(1)
	if familiar_count >= 15:
		unlock(2)
	if familiar_count >= 30:
		unlock(3)
