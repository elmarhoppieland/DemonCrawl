@tool
extends AtlasTexture
class_name CollectibleTexture

# ==============================================================================
var collectible: Collectible :
	set(value):
		if collectible == value:
			return
		
		collectible = value
		
		if collectible:
			atlas = collectible.get_atlas()
			region = collectible.get_atlas_region()
		else:
			atlas = null
			region = Rect2(0, 0, 16, 16)
		
		collectible_changed.emit()
# ==============================================================================
signal collectible_changed()
# ==============================================================================

func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	
	if Engine.is_editor_hint():
		props.append({
			"name": "collectible_script",
			"type": TYPE_OBJECT,
			"class_name": "Script",
			"usage": PROPERTY_USAGE_EDITOR,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Script"
		})
	
	return props


func _set(property: StringName, value: Variant) -> bool:
	if property == &"collectible_script":
		if value == null:
			collectible = null
			return true
		
		if not value is Script:
			return false
		
		collectible = value.new()
		return true
	
	return false


func _get(property: StringName) -> Variant:
	if property == &"collectible_script":
		return collectible.get_script() if collectible else null
	
	return null


func _property_can_revert(_property: StringName) -> bool:
	return true


func _property_get_revert(property: StringName) -> Variant:
	if property == &"collectible_script":
		return null
	
	return get_script().get_property_default_value(property)
