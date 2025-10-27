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
		EffectManager.propagate(get_quest().get_object_effects().interact_failed, self, handled)
	
	if handled:
		EffectManager.propagate(get_quest().get_object_effects().used, self)
		if _clear_on_collect():
			clear()
	else:
		_collect_failed()


func try_collect() -> bool:
	var handled := _collect()
	if not handled:
		handled = EffectManager.propagate_mutable(get_quest().get_object_effects().handle_interact_failed, 1, self, handled)
		EffectManager.propagate(get_quest().get_object_effects().interact_failed, self, handled)
	
	if handled:
		EffectManager.propagate(get_quest().get_object_effects().used, self)
		if _clear_on_collect():
			clear()
	
	return handled


## Virtual method. Called when the player collects this [Loot], usually when it is
## interacted with. Should return whether the collection was successful.
@abstract func _collect() -> bool


## Virtual method. Should return [code]true[/code] if the [Loot] should be immediately
## cleared when it is successfully collected. If this returns [code]false[/code],
## the [method _collect] method should provide another way of clearing this object.
func _clear_on_collect() -> bool:
	return true


func _collect_failed() -> void:
	pass
