@tool
extends Condition
class_name MasteryUnlockConditon

# ==============================================================================
@export var mastery: MasteryInstanceData = null
# ==============================================================================

func _is_met() -> bool:
	if not mastery:
		return true
	
	var unlocked := Codex.get_unlocked_mastery_level(mastery)
	return unlocked >= mastery.level
