@tool
extends Resource
class_name ItemData

# ==============================================================================
@export var name := "" :
	set(value):
		if description.is_empty() or name.to_snake_case().replace("_", "-") + ".description":
			if value.is_empty():
				description = ""
			else:
				description = value.to_snake_case().replace("_", "-") + ".description"
		name = value
		emit_changed()

@export_multiline var description := ""
@export var mana := 0
@export var cost := 0
@export var tags: Array[String] = []
@export var icon: Texture2D = null
@export var item_script: Script = null
# ==============================================================================

func _property_can_revert(property: StringName) -> bool:
	return property in [&"description", &"name", &"item_script"]


func _property_get_revert(property: StringName) -> Variant:
	if property == &"description":
		if name.is_empty():
			return ""
		return name.to_snake_case().replace("_", "-") + ".description"
	if property == &"name":
		return "item." + resource_path.get_file().get_basename().to_snake_case().replace("_", "-")
	if property == &"item_script":
		if item_script:
			return null
		
		var path := resource_path.get_basename() + ".gd"
		if ResourceLoader.exists(path):
			return load(path)
	
	return null


## Creates a new [Item] for this [ItemData].
func create() -> Item:
	return item_script.new(self)


func can_find(quest: Quest, ignore_items_in_inventory: bool) -> bool:
	if ignore_items_in_inventory:
		return true
	
	var base := item_script.get_base_script()
	while base != null and base != ConsumableItem:
		base = base.get_base_script()
	if base == ConsumableItem:
		return true
	
	for item in quest.get_inventory().get_items():
		if item.get_script() == item_script:
			return false
	
	return true


func _to_string() -> String:
	return "<ItemData#%s>" % name
