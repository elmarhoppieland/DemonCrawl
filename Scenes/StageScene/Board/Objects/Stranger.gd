@tool
extends CellObject
class_name Stranger

# ==============================================================================

func activate() -> void:
	_activate()


func _activate() -> void:
	pass


func _get_texture() -> Texture2D:
	return get_theme_icon(UserClassDB.script_get_class(get_script()).to_snake_case(), "Stranger").duplicate()
