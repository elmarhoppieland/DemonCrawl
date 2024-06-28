@tool
extends Resource
class_name ItemData

# ==============================================================================
const TYPE_COLORS := {
	Item.Type.PASSIVE: Color("00000000"),
	Item.Type.CONSUMABLE: Color("14a46480"),
	Item.Type.MAGIC: Color("2a6eb080"),
	Item.Type.OMEN: Color("bc383880"),
	Item.Type.LEGENDARY: Color("b3871a80")
}
# ==============================================================================
@export var name := "" :
	set(value):
		if description.is_empty() or description == name.to_snake_case().to_upper() + "_DESCRIPTION":
			if value.is_empty():
				description = ""
			else:
				description = value.to_snake_case().to_upper() + "_DESCRIPTION"
		name = value
@export_multiline var description := ""
@export var type := Item.Type.PASSIVE
@export var cost := 0
@export var atlas_region := Rect2(0, 0, 16, 16)
# ==============================================================================

func get_color() -> Color:
	return TYPE_COLORS[type]


func get_item_script() -> Script:
	return ResourceLoader.load(resource_path.get_slice(".", 0) + ".gd")


func _property_can_revert(_property: StringName) -> bool:
	return true


func _property_get_revert(property: StringName) -> Variant:
	if property == &"description":
		if name.is_empty():
			return ""
		return name.to_snake_case().to_upper() + "_DESCRIPTION"
	
	return get_script().get_property_default_value(property)
