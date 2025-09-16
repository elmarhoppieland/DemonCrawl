extends Node
class_name TooltipContext

# ==============================================================================
static var _current: TooltipContext = null : get = get_current
# ==============================================================================
signal process_text(text: String)
# ==============================================================================

static func get_current() -> TooltipContext:
	return _current


static func clear_current() -> void:
	_current = null


func set_as_current() -> void:
	_current = self


func get_text(text: String) -> String:
	return EffectManager.propagate_mutable(process_text, 0, text)
