extends RefCounted
class_name Quest

## A single quest with any amount of stages.

# ==============================================================================
# SavesManager.get_value("quest_name", Quest, "")
static var quest_name: String = Eternal.create("") ## The name of the quest.
# SavesManager.get_value("stages", Quest, [] as Array[Stage])
static var stages: Array[Stage] = Eternal.create([] as Array[Stage]) ## The stages in the quest.
# ==============================================================================

static func start_new(rng: RandomNumberGenerator) -> void:
	QuestsOverview.selected_quest.pack().generate(rng)
	
	Stats.max_life = QuestsOverview.selected_difficulty.get_starting_lives()
	Stats.life = Stats.max_life
	Stats.defense = 0
	Stats.coins = 0
	
	PlayerStats.reset()
	
	EffectManager.propagate_call("quest_start")
	
	Toasts.add_debug_toast("Quest started: %s on difficulty %s" % [TranslationServer.tr(Quest.quest_name), QuestsOverview.selected_difficulty.get_name()])


static func unlock_next_stage(stage: Stage, skip_special_stages: bool) -> void:
	var index := stages.find(stage) + 1
	if index >= stages.size():
		return
	
	var next_stage := stages[index]
	next_stage.locked = false
	
	if skip_special_stages and next_stage is SpecialStage:
		unlock_next_stage(next_stage, skip_special_stages)


static func finish() -> void:
	EffectManager.propagate_call("quest_finish")
	
	stages.clear()
	
	PlayerFlags.add_flag("%s/%s" % [
		QuestsOverview.selected_difficulty.get_name(),
		Quest.quest_name
	])
