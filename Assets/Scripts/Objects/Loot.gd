@tool
extends CellObject
class_name Loot

# ==============================================================================

func _interact() -> void:
	collect()


func collect() -> void:
	var handled := _collect()
	if handled:
		EffectManager.propagate(get_stage_instance().get_effects().object_used, [self])
		return
	
	handled = EffectManager.propagate(get_stage_instance().get_effects().handle_object_interact_failed, [self, handled], 1)
	EffectManager.propagate(get_stage_instance().get_effects().object_interact_failed, [self, handled])


func _collect() -> bool:
	return false


func get_value(default: int, value_name: StringName) -> int:
	return EffectManager.propagate(get_stage_instance().get_effects().get_object_value, [self, default, value_name], 1)
