@tool
extends Condition
class_name FlagCondition

# ==============================================================================
## The flag to use. This condition is met if the player has the given flag.
@export var flag := ""
## If [code]true[/code], inverts this condition. This means that it is met if the
## player does [b]not[/b] have the [member flag].
@export var invert := false
# ==============================================================================

func _is_met() -> bool:
	return invert != PlayerFlags.has_flag(flag)
