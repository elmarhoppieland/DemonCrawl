@tool
extends CellObject
class_name Stranger

# ==============================================================================
var _script_name := "" :
	get:
		if _script_name.is_empty():
			_script_name = UserClassDB.script_get_class(get_script())
		return _script_name
# ==============================================================================

func activate() -> void:
	_activate()


func _activate() -> void:
	pass


func _get_texture() -> Texture2D:
	return get_theme_icon(_script_name.to_snake_case(), "Stranger").duplicate()


func _aura_apply() -> void:
	if get_cell().get_aura() is Burning:
		kill()


func _cell_enter() -> void:
	_aura_apply()


func can_afford() -> bool:
	return _can_afford()


func _can_afford() -> bool:
	return true


func _can_interact() -> bool:
	return true
