@tool
@abstract
extends Resource
class_name Condition

# ==============================================================================

## Returns whether this [Condition] is met.
func is_met() -> bool:
	return _is_met()


## Virtual method. Should return whether this [Condition] is met.
@abstract func _is_met() -> bool
