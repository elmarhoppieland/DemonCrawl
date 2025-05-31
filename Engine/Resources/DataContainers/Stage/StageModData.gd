@tool
extends Resource
class_name StageModData

# ==============================================================================
@export var name := "STAGE_MOD_" + resource_path.get_file().get_basename().to_snake_case().to_upper() :
	set(value):
		if description.is_empty() or description == name.to_snake_case().to_upper() + "_DESCRIPTION":
			if value.is_empty():
				description = ""
			else:
				description = value.to_snake_case().to_upper() + "_DESCRIPTION"
		name = value
@export_multiline var description := ""
@export var difficulty := 0
@export var atlas_region := Rect2(0, 0, 10, 10)
@export var atlas: Texture2D = preload("res://Assets/Sprites/stage_mods.png")
# ==============================================================================

func get_mod_script() -> Script:
	return ResourceLoader.load(resource_path.get_basename() + ".gd")


static func from_path(path: String) -> StageModData:
	if path.is_relative_path():
		path = "res://Assets/mods/".path_join(path)
	
	return ResourceLoader.load(path.get_basename() + ".tres")


func _property_can_revert(property: StringName) -> bool:
	return get_script().get_script_property_list().any(func(prop: Dictionary) -> bool:
		return prop.name == property
	)


func _property_get_revert(property: StringName) -> Variant:
	if property == &"description":
		if name.is_empty():
			return ""
		return name.to_snake_case().to_upper() + "_DESCRIPTION"
	if property == &"name":
		return "STAGE_MOD_" + resource_path.get_file().get_basename().to_snake_case().to_upper()
	if property == &"atlas":
		return preload("res://Assets/Sprites/stage_mods.png")
	
	return get_script().get_property_default_value(property)
