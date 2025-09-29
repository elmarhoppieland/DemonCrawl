extends MasteryUnlocker

# ==============================================================================

func _enter_tree() -> void:
	get_quest().won.connect(_quest_win)


func _exit_tree() -> void:
	get_quest().won.disconnect(_quest_win)


func _quest_win() -> void:
	var bubbles := 0
	for orb in get_quest().get_orb_manager().get_orbs():
		if orb is Bubble:
			bubbles += 1
			if bubbles >= 10:
				unlock(1)
			if bubbles >= 20:
				unlock(2)
			if bubbles >= 30:
				unlock(3)
