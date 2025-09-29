@tool
extends Condition
class_name FlagCondition

# ==============================================================================
@export var flag := ""
@export var invert := false
# ==============================================================================

func _is_met() -> bool:
	return invert != PlayerFlags.has_flag(flag)
