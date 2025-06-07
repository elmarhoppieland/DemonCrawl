@tool
extends Condition
class_name MasteryUnlockConditon

# ==============================================================================
@export var mastery: Mastery :
	set(value):
		_mastery_weakref = weakref(value)
	get:
		return _mastery_weakref.get_ref() if _mastery_weakref else null
# ==============================================================================
var _mastery_weakref: WeakRef = null
# ==============================================================================

func _is_met() -> bool:
	if not mastery:
		return true
	
	for unlocked in Codex.unlocked_masteries:
		if unlocked.get_script() == mastery.get_script():
			return unlocked.level >= mastery.level
	
	return false
