@tool
@abstract
extends CellObject
class_name Loot

# ==============================================================================

func _interact() -> void:
	collect()


func collect() -> void:
	var handled := _collect()
	if not handled:
		handled = EffectManager.propagate_mutable(get_quest().get_object_effects().handle_interact_failed, 1, self, handled)
		EffectManager.propagate(get_quest().get_object_effects().interact_failed, [self, handled])
	
	if handled:
		EffectManager.propagate(get_quest().get_object_effects().used, [self])
		clear()
	else:
		_collect_failed()


func try_collect() -> bool:
	var handled := _collect()
	if not handled:
		handled = EffectManager.propagate_mutable(get_quest().get_object_effects().handle_interact_failed, 1, self, handled)
		EffectManager.propagate(get_quest().get_object_effects().interact_failed, [self, handled])
	
	if handled:
		EffectManager.propagate(get_quest().get_object_effects().used, [self])
		clear()
	
	return handled


## Virtual method. Called when the player collects this [Loot], usually when it is
## interacted with. Should return whether the collection was successful.
@abstract func _collect() -> bool


func _collect_failed() -> void:
	pass
