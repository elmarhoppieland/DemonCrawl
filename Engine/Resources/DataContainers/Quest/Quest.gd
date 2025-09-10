@tool
extends Node
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

@export var selected_stage_idx := 0 :
	set(value):
		selected_stage_idx = value
		emit_changed()

@export var _current_stage: StageInstance = null : set = _set_current_stage, get = get_current_stage

@export var heirlooms_active := true :
	set(value):
		heirlooms_active = value
		emit_changed()
# ==============================================================================
var _stage_effects := StageInstance.StageEffects.new() : get = get_stage_effects
var _effects := QuestEffects.new() : get = get_effects

var _immunity := Immunity.create_immunity_list() : get = get_immunity
# ==============================================================================
signal current_stage_changed()

signal started()
@warning_ignore("unused_signal") signal lost()
signal won()
#signal loaded()
#signal unloaded()

signal changed()
# ==============================================================================

func emit_changed() -> void:
	changed.emit()

#region internals

func _init() -> void:
	name = "Quest"


func _ready() -> void:
	var parent := get_mastery_unlockers_parent()
	var unlockers := DemonCrawl.get_full_registry().mastery_unlockers
	var unlocker_count := unlockers.size()
	for i in unlocker_count:
		var unlocker := unlockers[i]
		
		if get_mastery_unlockers().any(unlocker.unlocker_script.instance_has):
			continue
		
		parent.add_child(unlocker.create())
	
	get_event_bus_manager()

#endregion

#region current

static func _set_current(value: Quest) -> void:
	var old := _current
	_current = value
	if old != value:
		if old and old.is_inside_tree():
			old.queue_free()
		if value:
			if not value.is_inside_tree():
				Engine.get_main_loop().root.add_child(value)
			
			(func() -> void:
				if not value.is_node_ready():
					await value.ready
				value.get_tooltip_context().set_as_current()
			).call()
		else:
			TooltipContext.clear_current()
		
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


func _set_current_stage(current_stage: StageInstance) -> void:
	if current_stage == _current_stage:
		return
	
	if _current_stage:
		for effect in (StageInstance.StageEffects as Script).get_script_signal_list():
			var effect_signal: Signal = _current_stage.get_effects().get(effect.name)
			var callable := EffectManager.propagate_forward(get_stage_effects().get(effect.name))
			effect_signal.disconnect(callable)
		
		_current_stage.get_immunity().remove_forwarded_immunity(get_immunity())
		
		_current_stage.get_timer().second_passed.disconnect(EffectManager.propagate.bind(get_effects().stage_second_passed))
		_current_stage.get_status_timer().second_passed.disconnect(EffectManager.propagate.bind(get_effects().status_effect_second_passed))
		
		_current_stage.finished.disconnect(_on_stage_finished.bind(_current_stage))
	
	_current_stage = current_stage
	
	if current_stage:
		for effect in (StageInstance.StageEffects as Script).get_script_signal_list():
			var effect_signal: Signal = current_stage.get_effects().get(effect.name)
			var callable := EffectManager.propagate_forward(get_stage_effects().get(effect.name))
			effect_signal.connect(callable)
		
		current_stage.get_immunity().add_forwarded_immunity(get_immunity())
		
		current_stage.get_timer().second_passed.connect(EffectManager.propagate.bind(get_effects().stage_second_passed))
		current_stage.get_status_timer().second_passed.connect(EffectManager.propagate.bind(get_effects().status_effect_second_passed))
		
		current_stage.finished.connect(_on_stage_finished.bind(_current_stage))
	
	current_stage_changed.emit()


## Returns the currently active [StageInstance].
func get_current_stage() -> StageInstance:
	return _current_stage


func has_current_stage() -> bool:
	return _current_stage != null


func start_stage(stage: Stage) -> StageInstance:
	if _current_stage != null:
		Debug.log_error("Cannot start a stage, since one is already running.")
		return null
	
	_current_stage = stage.create_instance()
	
	return _current_stage

#endregion

#region global utils

func add_stage(stage: Stage) -> void:
	get_stages_parent().add_child(stage)


func get_stage(index: int) -> Stage:
	return get_stages_parent().get_child(index)


func start() -> void:
	started.emit()


#func notify_loaded() -> void:
	#_mastery_unlockers.clear()
	#
	#var unlockers: Array[MasteryUnlocker] = []
	#var unlocker_count := DemonCrawl.get_full_registry().mastery_unlockers.size()
	#unlockers.resize(unlocker_count)
	#for i in unlocker_count:
		#var unlocker := DemonCrawl.get_full_registry().mastery_unlockers[i]
		#
		#for exported_unlocker in _exported_mastery_unlockers:
			#if exported_unlocker.get_script() == unlocker.get_script():
				#unlockers[i] = exported_unlocker
				#unlocker = null
		#
		#if unlocker:
			#unlockers[i] = unlocker.duplicate()
	#
	#_mastery_unlockers = unlockers
	#
	#loaded.emit()


#func notify_unloaded() -> void:
	#_mastery_unlockers.clear()
	#
	#unloaded.emit()


## Unlocks the next stage of the quest, starting at [code]stage[/code].
func unlock_next_stage(skip_special_stages: bool = true, start_stage_index: int = selected_stage_idx) -> void:
	if start_stage_index + 1 >= get_stages().size():
		return
	
	var next_stage := get_stages()[start_stage_index + 1]
	next_stage.locked = false
	
	if skip_special_stages and next_stage is SpecialStage:
		unlock_next_stage(skip_special_stages, start_stage_index + 1)


## Finishes this quest.
func finish() -> void:
	for unlocker in get_mastery_unlockers():
		unlocker.notify_quest_won()
	
	won.emit()
	
	Effects.quest_finish(self)
	
	#PlayerFlags.add_flag("%s/%s" % [
		#source_difficulty.name,
		#source_file.name
	#])
	
	var data := QuestsManager.get_completion_data(source_file)
	data.completion_count += 1
	if data.best_score < get_attributes().score:
		data.best_score = get_attributes().score
	data.save()
	
	while GuiLayer.get_mastery_achieved_popup().is_popup_visible():
		await GuiLayer.get_mastery_achieved_popup().popup_hidden
	
	#notify_unloaded()


func _on_stage_finished(stage_instance: StageInstance) -> void:
	if get_mastery():
		get_mastery().gain_charge()
	
	var stages := get_stages()
	
	if stage_instance.get_stage() in stages:
		var idx := stages.find(stage_instance.get_stage()) + 1
		while idx < stages.size():
			var next_stage := stages[idx]
			next_stage.locked = false
			if next_stage is not SpecialStage:
				break
			idx += 1
		
		if is_finished():
			await finish()
			
			if Quest.get_current() == self:
				Quest.clear_current()
			
			Eternity.save()
			
			# TODO: send player to "quest finished" scene
			SceneManager.change_scene_to_file("res://Engine/Scenes/MainMenu/MainMenu.tscn")
			
			return
	
	if stage_instance == get_current_stage():
		_current_stage = null
	
	stage_instance.queue_free()
	
	Eternity.save()
	
	SceneManager.change_scene_to_file("res://Engine/Scenes/StageSelect/StageSelect.tscn")

#endregion

#region getters

func get_stages_parent() -> Node:
	if not has_node("Stages"):
		var stages_parent := Node.new()
		stages_parent.name = "Stages"
		add_child(stages_parent)
	return get_node("Stages")


func get_components_parent() -> Node:
	if not has_node("Components"):
		var components_parent := Node.new()
		components_parent.name = "Components"
		add_child(components_parent)
	return get_node("Components")


func get_stages() -> Array[Stage]:
	var stages: Array[Stage] = []
	stages.assign(get_stages_parent().get_children())
	return stages


func is_finished() -> bool:
	return get_stages().all(func(stage: Stage) -> bool: return stage is SpecialStage or stage.completed)


## Returns the currently selected [Stage].
func get_selected_stage() -> Stage:
	return get_stages()[selected_stage_idx]


#func _set_inventory(inventory: QuestInventory) -> void:
	#_inventory = inventory
	#inventory.set_quest(self)


func get_inventory() -> QuestInventory:
	for child in get_components_parent().get_children():
		if child is QuestInventory:
			return child
	
	var inventory := QuestInventory.new()
	get_components_parent().add_child(inventory)
	return inventory


#func _set_stats(stats: QuestStats) -> void:
	#_stats = stats
	#stats.set_quest(self)


func get_stats() -> QuestStats:
	for child in get_components_parent().get_children():
		if child is QuestStats:
			return child
	
	var stats := QuestStats.new()
	get_components_parent().add_child(stats)
	return stats


#func _set_player_attributes(player_attributes: QuestPlayerAttributes) -> void:
	#_player_attributes = player_attributes
	#player_attributes.set_quest(self)


func get_attributes() -> QuestPlayerAttributes:
	for child in get_components_parent().get_children():
		if child is QuestPlayerAttributes:
			return child
	
	var attributes := QuestPlayerAttributes.new()
	get_components_parent().add_child(attributes)
	return attributes


#func set_mastery(mastery: Mastery) -> void:
	#if _mastery:
		#_mastery.quest = null
		#_mastery.notify_unequipped()
	#_mastery = mastery
	#if mastery:
		#mastery.quest = self
		#mastery.initialize_on_quest()


func equip_mastery(mastery: Mastery) -> void:
	if has_mastery():
		clear_mastery()
	add_child(mastery)


func clear_mastery() -> void:
	get_mastery().queue_free()


func get_mastery() -> Mastery:
	for child in get_children():
		if child is Mastery:
			return child
	return null


func has_mastery() -> bool:
	return get_mastery() != null


func get_orb_manager() -> OrbManager:
	return _get_component(OrbManager)


func get_status_manager() -> StatusEffectsManager:
	return _get_component(StatusEffectsManager)


func get_action_manager() -> ActionManager:
	return _get_component(ActionManager)


func get_item_pool() -> ItemPool:
	return _get_component(ItemPool)


func get_tooltip_context() -> TooltipContext:
	return _get_component(TooltipContext)


func get_event_bus_manager() -> EventBusManager:
	return _get_component(EventBusManager, self, func() -> EventBusManager:
		var instance: EventBusManager = _add_component(EventBusManager, self)
		instance.event_owner = self
		return instance
	)


func get_event_bus(script: Script) -> EventBus:
	return get_event_bus_manager().get_event_bus(script)


func _get_component(component_script: Script, parent: Node = get_components_parent(), add_method: Callable = _add_component.bind(component_script, parent)) -> Node:
	for child in parent.get_children():
		if component_script.instance_has(child):
			return child
	
	return add_method.call()


func _add_component(component_script: Script, parent: Node = get_components_parent()) -> Node:
	var instance: Node = component_script.new()
	parent.add_child(instance)
	return instance


func get_mastery_unlockers_parent() -> Node:
	if not has_node("MasteryUnlockers"):
		var unlockers_parent := Node.new()
		unlockers_parent.name = "MasteryUnlockers"
		add_child(unlockers_parent)
	return get_node("MasteryUnlockers")


func get_mastery_unlockers() -> Array[MasteryUnlocker]:
	var unlockers: Array[MasteryUnlocker] = []
	unlockers.assign(get_mastery_unlockers_parent().get_children())
	return unlockers


func get_stage_effects() -> StageInstance.StageEffects:
	return _stage_effects


func get_effects() -> QuestEffects:
	return _effects


func get_immunity() -> Immunity.ImmunityList:
	return _immunity

#endregion


class QuestEffects:
	@warning_ignore("unused_signal") signal status_effect_second_passed()
	@warning_ignore("unused_signal") signal stage_second_passed()
