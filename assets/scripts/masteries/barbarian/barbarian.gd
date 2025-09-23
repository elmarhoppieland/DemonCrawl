@tool
extends Mastery
class_name Barbarian

# ==============================================================================
const RottingHead := preload("res://assets/items/rotting_head.gd")
# ==============================================================================
@export var strangers_killed := 0
# ==============================================================================

func _enable() -> void:
	get_quest().get_object_effects().handle_interact_failed.connect(_object_interact_failed)
	get_quest().get_object_effects().killed.connect(_object_kill)


func _disable() -> void:
	get_quest().get_object_effects().handle_interact_failed.disconnect(_object_interact_failed)
	get_quest().get_object_effects().killed.disconnect(_object_kill)


func _object_interact_failed(object: CellObject, handled: bool) -> bool:
	if not object is Stranger:
		return handled
	if level < 1:
		return handled
	
	if not (object as Stranger).can_afford():
		object.kill()
	
	return true


func _object_kill(object: CellObject) -> void:
	if not object is Stranger:
		return
	if level < 2:
		return
	
	get_rotting_head().invoke()
	
	if level < 3:
		return
	
	strangers_killed += 1


func _ability() -> void:
	get_rotting_head().create_status(RottingHead.Status).set_seconds(RottingHead.DURATION_SEC * strangers_killed).set_joined().start()


func _get_max_charges() -> int:
	return 3


func get_rotting_head() -> RottingHead:
	for child in get_children():
		if child is RottingHead:
			return child
	
	var rotting_head := RottingHead.new()
	add_child(rotting_head)
	return rotting_head
