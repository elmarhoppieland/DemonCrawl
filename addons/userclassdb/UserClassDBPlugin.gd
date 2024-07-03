@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("__UserClassDBInitializer", "res://addons/userclassdb/UserClassDBInitializer.gd")
	ProjectSettings.set_setting("ucdb/settings/fallback_to_classdb", false)
	ProjectSettings.set_initial_value("ucdb/settings/fallback_to_classdb", false)


func _exit_tree() -> void:
	remove_autoload_singleton("__UserClassDBInitializer")
