extends Mastery

# ==============================================================================

func change_score(value: int) -> int:
	if level < 1:
		return value
	
	if value <= get_quest_instance().score:
		return value
	
	# simplified version of: PlayerStats.score + (value - PlayerStats.score) / 2
	return (get_quest_instance().score + value) / 2


func damage(amount: int, source: Object) -> int:
	if level < 1:
		return amount
	if amount < 1:
		return amount
	if not source is CellMonster:
		return amount
	
	if Stage.get_current().get_instance().needs_guess():
		Toasts.add_toast(tr("NOVICE_UNLUCKY_GUESS"), IconManager.get_icon_data("mastery0/novice").create_texture())
		return 1
	
	return amount


func death(_source: Object) -> void:
	if level < 2:
		return
	
	if get_quest_instance().score >= 300:
		get_quest_instance().score = 0
		get_quest_instance().revive()


func _ability() -> void:
	Stage.get_current().get_board().get_camera().focus_progress()
