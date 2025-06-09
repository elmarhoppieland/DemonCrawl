@tool
extends Mastery
class_name Novice

# ==============================================================================

func _quest_load() -> void:
	Effects.MutableSignals.change_score.connect(_change_score)
	Effects.MutableSignals.damage.connect(_damage)
	Effects.MutableSignals.death.connect(_death)


func _quest_unload() -> void:
	Effects.MutableSignals.change_score.disconnect(_change_score)
	Effects.MutableSignals.damage.disconnect(_damage)
	Effects.Signals.death.disconnect(_death)


func _change_score(value: int) -> int:
	if level < 1:
		return value
	
	if value <= get_attributes().score:
		return value
	
	return (get_attributes().score + value) / 2


func _damage(amount: int, source: Object) -> int:
	if level < 1:
		return amount
	if amount < 1:
		return amount
	if not source is Monster:
		return amount
	
	if StageInstance.get_current().needs_guess():
		Toasts.add_toast(tr("NOVICE_UNLUCKY_GUESS"), IconManager.get_icon_data("mastery1/Novice").create_texture())
		return 1
	
	return amount


func _death(_source: Object) -> void:
	if level < 2:
		return
	
	if get_attributes().score >= 300:
		get_attributes().score = 0
		get_stats().revive()


func _ability() -> void:
	var progress_cell := StageInstance.get_current().get_progress_cell()
	if progress_cell:
		StageInstance.get_current().get_board().get_camera().focus_on_cell(progress_cell)
	else:
		Toasts.add_toast(tr("MUST_GUESS"), IconManager.get_icon_data("mastery1/Novice").create_texture())


func _can_use_ability() -> bool:
	return StageInstance.has_current() and StageInstance.get_current().has_scene()


func _get_cost() -> int:
	return level


func _get_max_charges() -> int:
	return 1
