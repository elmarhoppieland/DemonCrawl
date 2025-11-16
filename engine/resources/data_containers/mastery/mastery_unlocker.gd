@abstract
extends Node
class_name MasteryUnlocker

# ==============================================================================
@export var data: MasteryUnlockerData = null
# ==============================================================================

@warning_ignore("shadowed_variable")
func _init(data: MasteryUnlockerData = null) -> void:
	self.data = data


func _enter_tree() -> void:
	if not get_quest().is_node_ready():
		await get_quest().ready
	
	_enable()


func _exit_tree() -> void:
	_disable()


## Virtual method. Called when this [MasteryUnlocker] is enabled, usually when it
## enters the scene tree.
func _enable() -> void:
	pass


## Virtual method. Called when this [MasteryUnlocker] is disabled, usually when it
## is about to exit the scene tree.
func _disable() -> void:
	pass


## Notifies the [MasteryUnlocker] that the current [Quest] has been won.
func notify_quest_won() -> void:
	_quest_win()


## Virtual method. Called whenever a [Quest] is won.
func _quest_win() -> void:
	pass


func unlock(level: int) -> void:
	if Codex.get_unlocked_mastery_level(data.data) < level:
		_unlock(level)
		await MasteryAchievedPopup.show_mastery(data.data.instantiate(level))


func _unlock(level: int) -> void:
	if Codex.get_unlocked_mastery_level(data.data) >= level:
		return
	
	var mastery := Codex.get_unlocked_mastery(data.data)
	if not mastery:
		if level > 1:
			return
		mastery = data.data.instantiate(level)
		Codex.unlocked_masteries.append(mastery)
	
	if mastery.level == level - 1:
		mastery.level = level


func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base
