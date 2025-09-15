@tool
extends CellObject
class_name Loot

# ==============================================================================

func _interact() -> void:
	collect()


func collect() -> void:
	var handled := _collect()
	if not handled:
		handled = EffectManager.propagate(get_quest().get_object_effects().handle_interact_failed, [self, handled], 1)
		EffectManager.propagate(get_quest().get_object_effects().interact_failed, [self, handled])
	
	if handled:
		EffectManager.propagate(get_quest().get_object_effects().used, [self])
		clear()
	else:
		_collect_failed()


func try_collect() -> bool:
	var handled := _collect()
	if not handled:
		handled = EffectManager.propagate(get_quest().get_object_effects().handle_interact_failed, [self, handled], 1)
		EffectManager.propagate(get_quest().get_object_effects().interact_failed, [self, handled])
	
	if handled:
		EffectManager.propagate(get_quest().get_object_effects().used, [self])
		clear()
	
	return handled


func _collect() -> bool:
	return false


func _collect_failed() -> void:
	pass
