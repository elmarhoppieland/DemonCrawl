extends MasteryUnlocker
class_name SurvivorUnlocker

# ==============================================================================

func _init() -> void:
	Promise.dynamic_signal(Quest.get_current, "won", Quest.current_changed).connect(_quest_win)


func _quest_win() -> void:
	if Quest.get_current().get_stats().life >= 10:
		unlock(1)
	if Quest.get_current().get_stats().life >= 20:
		unlock(2)
	if Quest.get_current().get_stats().life >= 30:
		unlock(3)
