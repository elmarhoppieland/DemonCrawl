@tool
@abstract
extends Resource
class_name Condition

# ==============================================================================

func is_met() -> bool:
	return _is_met()


@abstract func _is_met() -> bool
