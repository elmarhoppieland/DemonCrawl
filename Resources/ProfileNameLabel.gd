@tool
extends Label
class_name ProfileNameLabel

# ==============================================================================

func _enter_tree() -> void:
	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()


func _exit_tree() -> void:
	visibility_changed.disconnect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if Engine.is_editor_hint():
		text = "<profile-name>"
		return
	
	text = SavesManager.get_save_name()
