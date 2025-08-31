@tool
extends EditorScript


func _run() -> void:
	call_on_root()


func call_on_root() -> void:
	var root := get_tree().edited_scene_root
	var function := "_run_" + UserClassDB.script_get_class(root.get_script()).to_snake_case().to_lower()
	if has_method(function):
		call(function, root)


func get_tree() -> SceneTree:
	return Engine.get_main_loop()
