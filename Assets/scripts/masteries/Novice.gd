extends Mastery

# ==============================================================================

func change_score(value: int) -> int:
	if level < 1:
		return value
	
	if value <= get_attributes().score:
		return value
	
	return (get_attributes().score + value) / 2


func damage(amount: int, source: Object) -> int:
	if level < 1:
		return amount
	if amount < 1:
		return amount
	if not source is Monster:
		return amount
	
	if Stage.get_current().get_instance().needs_guess():
		Toasts.add_toast(tr("NOVICE_UNLUCKY_GUESS"), IconManager.get_icon_data("mastery0/novice").create_texture())
		return 1
	
	return amount


func death(_source: Object) -> void:
	if level < 2:
		return
	
	if get_attributes().score >= 300:
		get_attributes().score = 0
		get_stats().revive()


func _ability() -> void:
	Stage.get_current().get_board().get_camera().focus_progress()
