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

@export var _mastery: Mastery : get = get_mastery

@export var _projectile_manager := ProjectileManager.new() : get = get_projectile_manager

@export var __temp_aura := Aura.new()
# ==============================================================================

#region current

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

#endregion

#region static utils

## Starts a new [Quest], using the given [RandomNumberGenerator], and sets the current
## quest to the new quest.
static func start_new(rng: RandomNumberGenerator) -> void:
	_current = QuestsManager.selected_quest.pack().generate(rng)
	
	QuestsManager.selected_difficulty.apply_starting_values()
	
	# TODO: merge PlayerStats into QuestInstance
	#PlayerStats.reset()
	
	Effects.quest_start()

#endregion

#region global utils

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
	Effects.quest_finish()
	
	stages.clear()
	
	PlayerFlags.add_flag("%s/%s" % [
		QuestsManager.selected_difficulty.get_name(),
		name
	])


#endregion

#region getters

## Returns the currently selected [Stage].
func get_selected_stage() -> Stage:
	return stages[selected_stage_idx]


func get_inventory() -> QuestInventory:
	return _inventory


func get_stats() -> QuestStats:
	return _stats


func get_attributes() -> QuestPlayerAttributes:
	return _player_attributes


func get_mastery() -> Mastery:
	return _mastery


func get_projectile_manager() -> ProjectileManager:
	return _projectile_manager

#endregion
