@tool
extends Mastery
class_name Novice

# ==============================================================================

func _enter_tree() -> void:
	super()
	
	if not active:
		return
	
	get_quest().get_attributes().change_property.connect(_change_attribute)
	get_quest().get_stats().get_mutable_effects().damage.connect(_damage)
	get_quest().get_stats().get_mutable_effects().death.connect(_death)


func _exit_tree() -> void:
	super()
	
	if not active:
		return
	
	get_quest().get_attributes().change_property.disconnect(_change_attribute)
	get_quest().get_stats().get_mutable_effects().damage.disconnect(_damage)
	get_quest().get_stats().get_mutable_effects().death.disconnect(_death)


func _change_attribute(attribute: StringName, value: int) -> int:
	if attribute != &"score":
		return value
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
	
	if not get_quest().has_current_stage():
		return amount
	
	if get_quest().get_current_stage().needs_guess():
		Toasts.add_toast(tr("mastery.novice.guess_fail"), IconManager.get_icon_data("mastery1/Novice").create_texture())
		return 1
	
	return amount


func _death(_source: Object) -> void:
	if level < 2:
		return
	
	if get_attributes().score >= 300:
		get_attributes().score = 0
		get_stats().revive()


func _ability() -> void:
	var progress_cell := get_quest().get_current_stage().get_progress_cell()
	if progress_cell:
		get_quest().get_current_stage().get_board().get_camera().focus_on_cell(progress_cell)
	else:
		Toasts.add_toast(tr("mastery.novice.ability.fail"), IconManager.get_icon_data("mastery1/Novice").create_texture())


func _can_use_ability() -> bool:
	return get_quest().has_current_stage() and get_quest().get_current_stage().has_scene()


func _get_cost() -> int:
	return level


func _get_max_charges() -> int:
	return 1
