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


func _export_packed() -> Array:
	return []


static func _import_packed_static(script_name: String) -> Aura:
	var script := UserClassDB.class_get_script(script_name)
	return create(script)
