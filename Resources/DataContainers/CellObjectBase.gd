@tool
extends Resource
class_name CellObjectBase

# ==============================================================================
@export var base_script: GDScript :
	set(value):
		if not value:
			base_script = null
			notify_property_list_changed()
			return
		
		var base := value
		while base != CellObject:
			base = base.get_base_script()
			if not base:
				return
		
		base_script = value
		notify_property_list_changed()
# ==============================================================================
var _meta_props := {}
# ==============================================================================

@warning_ignore("shadowed_variable")
func _init(base_script: GDScript = null) -> void:
	self.base_script = base_script


func create(cell: CellData, stage: Stage = Stage.get_current()) -> CellObject:
	var instance := base_script.new(cell, stage) as CellObject
	for prop in _meta_props:
		instance.set(prop, _meta_props[prop])
	return instance


func can_spawn() -> bool:
	if not base_script:
		return false
	return CellObject.can_spawn(base_script)


func _get_property_list() -> Array[Dictionary]:
	if not base_script:
		return []
	
	return base_script.get_script_property_list().filter(func(a: Dictionary) -> bool:
		return not a.name.begins_with("_")
	)


func _get(property: StringName) -> Variant:
	if property in _meta_props:
		return _meta_props[property]
	return null


func _set(property: StringName, value: Variant) -> bool:
	if not base_script:
		return false
	
	if base_script.get_script_property_list().any(func(prop: Dictionary) -> bool: return prop.name == property):
		_meta_props[property] = value
		return true
	
	return false
