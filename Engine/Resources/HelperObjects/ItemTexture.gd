@tool
extends CollectibleTexture
#class_name ItemTexture

# ==============================================================================
var item: Item :
	set(value):
		if item == value:
			return
		
		item = value
		
		if item:
			region = item.data.atlas_region
		else:
			region = Rect2(0, 0, 16, 16)
		
		collectible_changed.emit()
# ==============================================================================

func _init() -> void:
	atlas = preload("res://Assets/Sprites/items.png")


func _get_property_list() -> Array[Dictionary]:
	var props := super()
	
	if Engine.is_editor_hint():
		props.append({
			"name": "item_script",
			"type": TYPE_OBJECT,
			"class_name": "Script",
			"usage": PROPERTY_USAGE_EDITOR,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Script"
		})
	
	return props


func _set(property: StringName, value: Variant) -> bool:
	if property == &"item_script":
		if value == null:
			item = null
			return true
		
		if not value is Script:
			return false
		
		item = value.new()
		return true
	
	return false


func _get(property: StringName) -> Variant:
	if property == &"item_script":
		return item.get_script() if item else null
	
	return null


func _property_can_revert(_property: StringName) -> bool:
	return true


func _property_get_revert(property: StringName) -> Variant:
	if property == &"item_script":
		return null
	
	return get_script().get_property_default_value(property)
