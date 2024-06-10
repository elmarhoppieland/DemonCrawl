extends LineEdit
class_name DCLineEdit

# ==============================================================================

func _enter_tree() -> void:
	focus_entered.connect(blink)


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
