@tool
extends Resource
class_name Quest

## A single quest with any amount of [Stage]s.

# ==============================================================================
static var _current: Quest = Eternal.create(null) : set = _set_current, get = get_current
# ==============================================================================
@export var name := "" : ## The name of the quest.
	set(value):
		name = value
		emit_changed()
@export var stages: Array[Stage] = [] : ## The stages in the quest.
	set(value):
		for stage in stages:
			if stage and stage.changed.is_connected(emit_changed):
				stage.changed.disconnect(emit_changed)
		
		stages = value
		
		for stage in value:
			if stage:
				stage.changed.connect(emit_changed)
		
		emit_changed()
	get:
		return stages

@export var _instance: QuestInstance : get = get_instance
# ==============================================================================

static func _set_current(value: Quest) -> void:
	_current = value


## Returns the current quest.
static func get_current() -> Quest:
	return _current


## Returns whether the player is currently in a [Quest].
static func has_current() -> bool:
	return get_current() != null


## Sets this [Quest] as the current quest. Future calls to [method get_current] will
## return this [Quest].
func set_as_current() -> void:
	_current = self


## Starts a new [Quest], using the given [RandomNumberGenerator], and sets the current
## quest to the new quest.
static func start_new(rng: RandomNumberGenerator) -> void:
	_current = QuestsManager.selected_quest.pack().generate(rng)
	
	QuestsManager.selected_difficulty.apply_starting_values()
	
	# TODO: merge PlayerStats into QuestInstance
	#PlayerStats.reset()
	
	Effects.quest_start()


## Unlocks the next stage of the quest, starting at [code]stage[/code].
func unlock_next_stage(skip_special_stages: bool = true, start_stage_index: int = get_instance().selected_stage_idx) -> void:
	if start_stage_index + 1 >= stages.size():
		return
	
	var next_stage := stages[start_stage_index + 1]
	next_stage.locked = false
	
	if skip_special_stages and next_stage is SpecialStage:
		unlock_next_stage(skip_special_stages, start_stage_index + 1)


## Finishes this quest.
func finish() -> void:
	Effects.quest_finish()
	
	stages.clear()
	
	PlayerFlags.add_flag("%s/%s" % [
		QuestsManager.selected_difficulty.get_name(),
		name
	])


## Returns the currently selected [Stage].
func get_selected_stage() -> Stage:
	return get_instance().get_selected_stage()


## Returns a [QuestInstance] for this [Quest]. Reuses the same one if one was already created.
func get_instance() -> QuestInstance:
	if not _instance:
		_instance = QuestInstance.new()
		_instance.set_quest(self)
	return _instance


## Clears this [Quest]'s [QuestInstance]. The next call to [method get_instance] will
## create a new instance.
func clear_instance() -> void:
	_instance = null
