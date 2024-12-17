@tool
extends EditorPlugin


func _enter_tree() -> void:
	#add_autoload_singleton("__AutoThreadAccessor", "res://addons/AutoThread/AutoTheadAccessor.gd")
	pass


func _exit_tree() -> void:
	#remove_autoload_singleton("__AutoThreadAccessor")
	pass
