@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("__UserClassDBInitializer", "res://addons/userclassdb/UserClassDBInitializer.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("__UserClassDBInitializer")
