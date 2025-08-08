@tool
extends Condition
class_name MasteryUnlockConditon

# ==============================================================================
@export var mastery: Mastery.MasteryData = null
# ==============================================================================

func _is_met() -> bool:
	if not mastery:
		return true
	
	var unlocked := Codex.get_unlocked_mastery(mastery)
	if unlocked:
		return unlocked.level >= mastery.level
	return false
