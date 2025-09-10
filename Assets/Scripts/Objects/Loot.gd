@tool
extends CellObject
class_name Loot

# ==============================================================================

func _interact() -> void:
	collect()


func collect() -> void:
	var handled := _collect()
	if handled:
		EffectManager.propagate(get_quest().get_object_effects().used, [self])
		return
	
	handled = EffectManager.propagate(get_quest().get_object_effects().handle_interact_failed, [self, handled])
	EffectManager.propagate(get_quest().get_object_effects().interact_failed, [self, handled])


func _collect() -> bool:
	return false
