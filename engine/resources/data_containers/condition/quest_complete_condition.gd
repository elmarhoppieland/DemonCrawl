@tool
extends Condition
class_name QuestCompleteCondition

# ==============================================================================
@export var quest: QuestFile = null
# ==============================================================================

func _is_met() -> bool:
	# we cannot use the QuestsManager directly (cyclic reference?)
	return load("res://engine/resources/singletons/quests_manager.gd").is_completed(quest)
