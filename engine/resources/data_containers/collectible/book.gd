@tool
@abstract
extends PassiveItem
class_name Book

# ==============================================================================

func _enter_tree() -> void:
	if not is_active():
		return
	
	get_quest().get_object_effects().handle_interact_failed.connect(_handle_object_interact_failed)


func _exit_tree() -> void:
	if not is_active():
		return
	
	get_quest().get_object_effects().handle_interact_failed.disconnect(_handle_object_interact_failed)


func _handle_object_interact_failed(object: CellObject, handled: bool) -> bool:
	if object is not Heart:
		return handled
	
	activate()
	return true


func activate() -> void:
	_activate()
	
	EffectManager.propagate(get_stage_instance().get_item_effects().used, self)


func _activate() -> void:
	pass
