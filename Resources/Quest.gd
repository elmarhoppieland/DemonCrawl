extends RefCounted
class_name Quest

## A single quest with any amount of stages.

# ==============================================================================
static var quest_name: String = Eternal.create("") ## The name of the quest.
static var stages: Array[Stage] = Eternal.create([] as Array[Stage]) ## The stages in the quest.
static var selected_stage_idx: int = Eternal.create(0) ## The index of the selected [Stage].
# ==============================================================================

## Starts a new quest, using the given [RandomNumberGenerator].
static func start_new(rng: RandomNumberGenerator) -> void:
	QuestsOverview.selected_quest.pack().generate(rng)
	
	Stats.max_life = QuestsOverview.selected_difficulty.get_starting_lives()
	Stats.life = Stats.max_life
	Stats.defense = 0
	Stats.coins = 0
	
	PlayerStats.reset()
	
	EffectManager.propagate_call("quest_start")
	
	Toasts.add_debug_toast("Quest started: %s on difficulty %s" % [TranslationServer.tr(Quest.quest_name), QuestsOverview.selected_difficulty.get_name()])


## Unlocks the next stage of the quest, starting at [code]stage[/code].
static func unlock_next_stage(skip_special_stages: bool = true, start_stage_index: int = selected_stage_idx) -> void:
	if start_stage_index + 1 >= stages.size():
		return
	
	var next_stage := stages[start_stage_index + 1]
	next_stage.locked = false
	
	if skip_special_stages and next_stage is SpecialStage:
		unlock_next_stage(skip_special_stages, start_stage_index + 1)


## Finishes this quest.
static func finish() -> void:
	EffectManager.propagate_call("quest_finish")
	
	stages.clear()
	
	PlayerFlags.add_flag("%s/%s" % [
		QuestsOverview.selected_difficulty.get_name(),
		Quest.quest_name
	])


## Returns the currently selected [Stage].
static func get_selected_stage() -> Stage:
	return stages[selected_stage_idx]
