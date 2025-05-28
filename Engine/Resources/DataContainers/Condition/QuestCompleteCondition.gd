@tool
extends Condition
class_name QuestCompleteCondition

# ==============================================================================
@export var quest: QuestFile = null
# ==============================================================================

func _is_met() -> bool:
	# we cannot use the QuestsManager directly (cyclic reference?)
	return load("res://Engine/Resources/Singletons/QuestsManager.gd").is_completed(quest)
