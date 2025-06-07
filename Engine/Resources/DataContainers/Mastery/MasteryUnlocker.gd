extends RefCounted
class_name MasteryUnlocker

# ==============================================================================
static var _unlockers: Array[MasteryUnlocker] = []
# ==============================================================================

static func _static_init() -> void:
	await Promise.defer()
	
	for script_name in UserClassDB.get_inheriters_from_class(&"MasteryUnlocker"):
		_unlockers.append(UserClassDB.instantiate(script_name))


func unlock(level: int) -> void:
	var mastery := get_mastery()
	mastery.level = level
	for condition in mastery.get_conditions():
		if not condition.is_met():
			_unlock(level)
			await GuiLayer.get_mastery_achieved_popup().show_mastery(mastery)
			break


func _unlock(level: int) -> void:
	if level == 1:
		var mastery := get_mastery()
		mastery.level = 1
		Codex.unlocked_masteries.append(mastery)
		return
	
	for unlocked in Codex.unlocked_masteries:
		if UserClassDB.script_get_class(unlocked.get_script()) == get_mastery_class():
			if unlocked.level < level:
				unlocked.level = level
			return


func get_mastery() -> Mastery:
	return _get_mastery()


func _get_mastery() -> Mastery:
	return UserClassDB.instantiate(get_mastery_class())


func get_mastery_class() -> StringName:
	return _get_mastery_class()


func _get_mastery_class() -> StringName:
	return UserClassDB.script_get_class(get_script()).trim_suffix("Unlocker")
