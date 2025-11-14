@tool
@abstract
extends CellObject
class_name Landmark

# ==============================================================================
var _script_name := "" :
	get:
		if _script_name.is_empty():
			_script_name = UserClassDB.script_get_class(get_script())
		return _script_name
# ==============================================================================

func _get_texture() -> Texture2D:
	return get_theme_icon(_script_name.to_snake_case(), "Landmark").duplicate()
