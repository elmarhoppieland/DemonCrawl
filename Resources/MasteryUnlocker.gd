extends EffectScript
class_name MasteryUnlocker

# ==============================================================================
var mastery := ""
# ==============================================================================

func unlock(level: int) -> void:
	var flag := mastery + "_condition_" + str(level)
	
	if PlayerFlags.has_flag(flag):
		return
	
	PlayerFlags.add_flag(flag)
	
	MasteryUnlockPopup.show_unlock(mastery, level)
