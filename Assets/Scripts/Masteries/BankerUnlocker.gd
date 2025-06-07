extends MasteryUnlocker
class_name BankerUnlocker

# ==============================================================================

func _init() -> void:
	Promise.dynamic_signal(Quest.get_current, "won", Quest.current_changed).connect(_quest_win)


func _quest_win() -> void:
	if Quest.get_current().get_stats().coins >= 100:
		unlock(1)
	if Quest.get_current().get_stats().coins >= 200:
		unlock(2)
	if Quest.get_current().get_stats().coins >= 300:
		unlock(3)
