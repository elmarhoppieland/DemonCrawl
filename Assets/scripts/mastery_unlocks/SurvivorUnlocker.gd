extends MasteryUnlocker

# ==============================================================================

func _init() -> void:
	mastery = "survivor"


func quest_finish() -> void:
	if Stats.life >= 10:
		unlock(1)
	if Stats.life >= 20:
		unlock(2)
	if Stats.life >= 30:
		unlock(3)
