extends MasteryUnlocker
class_name SurvivorUnlocker

# ==============================================================================

func _init() -> void:
	var s := Promise.dynamic_signal(Quest.get_current, "won", Quest.current_changed)
	print(s.get_name())
	print(s.get_connections())
	print(s.get_object_id())
	print(s.get_object())
	s.connect(_quest_win)


func _quest_win() -> void:
	if Quest.get_current().get_stats().life >= 10:
		unlock(1)
	if Quest.get_current().get_stats().life >= 20:
		unlock(2)
	if Quest.get_current().get_stats().life >= 30:
		unlock(3)
