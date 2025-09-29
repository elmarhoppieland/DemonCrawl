extends MasteryUnlocker
class_name BankerUnlocker

# ==============================================================================

func _quest_win() -> void:
	if Quest.get_current().get_stats().coins >= 100:
		unlock(1)
	if Quest.get_current().get_stats().coins >= 200:
		unlock(2)
	if Quest.get_current().get_stats().coins >= 300:
		unlock(3)
