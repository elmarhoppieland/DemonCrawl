extends DCLineEdit

# ==============================================================================

func _ready() -> void:
	visibility_changed.connect(func(): if visible: grab_focus())
