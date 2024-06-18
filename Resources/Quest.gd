extends RefCounted
class_name Quest

## A single quest with any amount of stages.

# ==============================================================================
static var quest_name: String = SavesManager.get_value("quest_name", Quest, "") ## The name of the quest.
static var stages: Array[Stage] = SavesManager.get_value("stages", Quest, [] as Array[Stage]) ## The stages in the quest.
# ==============================================================================

static func unlock_next_stage(stage: Stage, skip_special_stages: bool) -> void:
	var index := stages.find(stage) + 1
	if index >= stages.size():
		return
	
	var next_stage := stages[index]
	next_stage.locked = false
	
	if skip_special_stages and next_stage is SpecialStage:
		unlock_next_stage(next_stage, skip_special_stages)


static func finish() -> void:
	stages.clear()
	
	PlayerFlags.add_flag("%s/%s" % [
		QuestsOverview.selected_difficulty.get_name(),
		Quest.quest_name
	])
