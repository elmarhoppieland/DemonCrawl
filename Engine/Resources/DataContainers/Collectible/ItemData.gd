@tool
extends Resource
class_name ItemData

# ==============================================================================
const Type := Item.Type
# ==============================================================================
@export var name := "" :
	set(value):
		if description.is_empty() or description == name.to_snake_case().to_upper() + "_DESCRIPTION":
			if value.is_empty():
				description = ""
			else:
				description = value.to_snake_case().to_upper() + "_DESCRIPTION"
		name = value
		emit_changed()

@export_multiline var description := ""
@export var type := Type.PASSIVE
@export var mana := 0
@export var cost := 0
@export var tags: Array[String] = []
@export var icon: Texture2D = null
# ==============================================================================

func _property_can_revert(property: StringName) -> bool:
	return property in [&"description", &"name"]


func _property_get_revert(property: StringName) -> Variant:
	if property == &"description":
		if name.is_empty():
			return ""
		return name.to_snake_case().to_upper() + "_DESCRIPTION"
	if property == &"name":
		return "ITEM_" + resource_path.get_file().get_basename().to_snake_case().to_upper()
	
	return null


## Creates a new [Item] for this [ItemData].
func create() -> Item:
	return Item.new(self)
