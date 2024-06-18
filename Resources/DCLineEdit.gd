extends LineEdit
class_name DCLineEdit

# ==============================================================================
var _focused := false
var _placeholder_text := placeholder_text
# ==============================================================================

func _enter_tree() -> void:
	focus_entered.connect(func():
		_focused = true
		blink()
		placeholder_text = ""
	)
	focus_exited.connect(func():
		_focused = false
		placeholder_text = _placeholder_text
	)


func _process(_delta: float) -> void:
	caret_column = text.length() - int(text.ends_with("_"))


func blink() -> void:
	if text.ends_with("_"):
		text = text.trim_suffix("_")
	else:
		text += "_"
	caret_column = text.length() - int(text.ends_with("_"))
	
	await Promise.new([get_tree().create_timer(0.5).timeout, focus_exited]).any()
	
	if has_focus():
		blink()
	elif text.ends_with("_"):
		text = text.trim_suffix("_")


func _set(property: StringName, value: Variant) -> bool:
	if property != &"placeholder_text":
		return false
	
	if _focused:
		_placeholder_text = value
		return true
	
	return false
