extends Resource
class_name MasteryUnlocker

# ==============================================================================

func _init() -> void:
	_ready()


## Virtual method. Called after this [MasteryUnlocker] has been initialized.
func _ready() -> void:
	pass


## Notifies the [MasteryUnlocker] that the given [Quest] has been won.
func notify_quest_won() -> void:
	_quest_win()


## Virtual method. Called whenever a [Quest] is won.
func _quest_win() -> void:
	pass


func unlock(level: int) -> void:
	var mastery := get_mastery()
	mastery.level = level
	for condition in mastery.get_conditions():
		if not condition.is_met():
			_unlock(level)
			await GuiLayer.get_mastery_achieved_popup().show_mastery(mastery)
			break


func _unlock(level: int) -> void:
	if Codex.get_unlocked_mastery_level(get_mastery_class()) >= level:
		return
	
	var mastery := Codex.get_unlocked_mastery(get_mastery_class())
	if not mastery:
		if level > 1:
			return
		mastery = get_mastery()
		Codex.unlocked_masteries.append(mastery)
	
	if mastery.level == level - 1:
		mastery.level = level


func get_mastery() -> Mastery:
	return _get_mastery()


func _get_mastery() -> Mastery:
	return UserClassDB.instantiate(get_mastery_class())


func get_mastery_class() -> StringName:
	return _get_mastery_class()


func _get_mastery_class() -> StringName:
	return UserClassDB.script_get_class(get_script()).trim_suffix("Unlocker")


func is_quest_export() -> bool:
	return _is_quest_export()


func _is_quest_export() -> bool:
	return false
