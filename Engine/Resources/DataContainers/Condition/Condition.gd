@tool
extends Resource
class_name Condition

# ==============================================================================

func is_met() -> bool:
	return _is_met()


func _is_met() -> bool:
	return false
