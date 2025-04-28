@tool
extends Resource
class_name Aura

# ==============================================================================
static var _instances := {}
# ==============================================================================

static func create(script: Script) -> Aura:
	if script in _instances:
		return _instances[script]
	
	var value: Aura = script.new()
	_instances[script] = value
	return value


func get_modulate() -> Color:
	return _get_modulate()


func _get_modulate() -> Color:
	return Color.WHITE


func _export_packed() -> Array:
	return []


static func _import_packed_static(script_name: String) -> Aura:
	var script := UserClassDB.class_get_script(script_name)
	return create(script)
