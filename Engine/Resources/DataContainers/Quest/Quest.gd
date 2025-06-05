@tool
extends Resource
class_name Quest

## A single quest with any amount of [Stage]s.

# ==============================================================================
static var _current: Quest = Eternal.create(null) : set = _set_current, get = get_current

static var current_changed := Signal() :
	get:
		if current_changed.is_null():
			(Quest as GDScript).add_user_signal("_current_changed")
			current_changed = Signal(Quest, "_current_changed")
		return current_changed
# ==============================================================================
@export var source_file: QuestFile = null
@export var source_difficulty: Difficulty = null

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
@export var selected_stage_idx := 0 :
	set(value):
		selected_stage_idx = value
		emit_changed()

@export var heirlooms_active := true :
	set(value):
		heirlooms_active = value
		emit_changed()

@export var _inventory := QuestInventory.new() : get = get_inventory
@export var _stats := QuestStats.new() : get = get_stats
@export var _player_attributes := QuestPlayerAttributes.new() : get = get_attributes

@export var _mastery: Mastery : set = set_mastery, get = get_mastery

@export var _orb_manager := OrbManager.new() : get = get_orb_manager
# ==============================================================================
signal started()
signal lost()
signal won()
signal loaded()
signal unloaded()

# ==============================================================================

#region current

static func _set_current(value: Quest) -> void:
	var different := _current != value
	_current = value
	if different:
		current_changed.emit()


## Returns the current quest.
static func get_current() -> Quest:
	return _current


## Returns whether the player is currently in a [Quest].
static func has_current() -> bool:
	return get_current() != null


## Sets the currently active [Quest] to [code]null[/code].
static func clear_current() -> void:
	_current = null


## Sets this [Quest] as the current quest. Future calls to [method get_current] will
## return this [Quest].
func set_as_current() -> void:
	_current = self

#endregion

#region static utils

## Starts a new [Quest], using the given [RandomNumberGenerator], and sets the current
## quest to the new quest.
#static func start_new() -> void:
	#_current = QuestsManager.selected_quest.generate()
	#
	#QuestsManager.selected_difficulty.apply_starting_values(_current)
	#
	## TODO: merge PlayerStats into QuestInstance
	##PlayerStats.reset()
	#
	#Effects.quest_start()

#endregion

#region global utils

func start() -> void:
	if get_mastery() and get_mastery().level >= 3:
		get_mastery().charges = 0
	
	started.emit()


func notify_loaded() -> void:
	loaded.emit()


func notify_unloaded() -> void:
	unloaded.emit()


## Unlocks the next stage of the quest, starting at [code]stage[/code].
func unlock_next_stage(skip_special_stages: bool = true, start_stage_index: int = selected_stage_idx) -> void:
	if start_stage_index + 1 >= stages.size():
		return
	
	var next_stage := stages[start_stage_index + 1]
	next_stage.locked = false
	
	if skip_special_stages and next_stage is SpecialStage:
		unlock_next_stage(skip_special_stages, start_stage_index + 1)


## Finishes this quest.
func finish() -> void:
	won.emit()
	
	Effects.quest_finish()
	
	PlayerFlags.add_flag("%s/%s" % [
		source_difficulty.name,
		source_file.name
	])
	
	var data := QuestsManager.get_completion_data(source_file)
	data.completion_count += 1
	if data.best_score < get_attributes().score:
		data.best_score = get_attributes().score
	data.save()


func notify_stage_finished(stage: Stage) -> void:
	stage.finish()
	
	if get_mastery():
		get_mastery().gain_charge()
	
	if stage not in stages:
		return
	
	if is_finished():
		finish()
		return
	
	var idx := stages.find(stage) + 1
	while idx < stages.size():
		var next_stage := stages[idx]
		next_stage.locked = false
		if not next_stage is SpecialStage:
			break
		idx += 1

#endregion

#region getters

func is_finished() -> bool:
	return stages.all(func(stage: Stage) -> bool: return stage is SpecialStage or stage.completed)


## Returns the currently selected [Stage].
func get_selected_stage() -> Stage:
	return stages[selected_stage_idx]


func get_inventory() -> QuestInventory:
	return _inventory


func get_stats() -> QuestStats:
	return _stats


func get_attributes() -> QuestPlayerAttributes:
	return _player_attributes


func set_mastery(value: Mastery) -> void:
	if _mastery:
		_mastery.quest = null
	_mastery = value
	if value:
		value.quest = self


func get_mastery() -> Mastery:
	return _mastery


func get_orb_manager() -> OrbManager:
	return _orb_manager

#endregion
